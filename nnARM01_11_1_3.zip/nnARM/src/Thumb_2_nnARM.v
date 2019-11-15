 /************************************************************************\
 **************************************************************************
 **************************************************************************
 **************************************************************************
 **************************************************************************
 *******+---------------------------------------------------------+********
 *******|+-------------------------------------------------------+|********
 *******|||                                                     |||********
 *******|||  Project  : nnARM                                   |||********
 *******|||  Module   : thumb_2_nnarm                           |||********
 *******|||  Designer : Mian                                    |||********
 *******|||  Date     : 11 July 2001                            |||********
 *******|||  Abstract : Converts 16 bit Thumb Instructions into |||********
 *******|||             32 Bit nnARM Instructions.              |||********
 *******|||  Ver      : 0.2                                     |||********
 *******|||  Comments :                                         |||********
 *******|||             Long Branches are not supported         |||********
 *******|||             For Undefined Inst,cond field is 4'b1111|||********
 *******|||                                                     |||********
 *******|+-------------------------------------------------------+|********
 *******+---------------------------------------------------------+********
 **************************************************************************
 **************************************************************************
 **************************************************************************
 **************************************************************************
 \************************************************************************/

module thumb_2_nnarm (
 
		//INPUTS
		in_AddressGoWithInstruction,
		cti                   , //Current THUMB Instruction
		reset                 ,
		clock                 , 

		//OUTPUTS
		out_ClearBit1,	//ssy add 2001 7 19
		out_AddressOfFirstHalf,//half word align, so bit 0 will be use to indicate whether there is a long branch with link
		arm_inst,
		//clear internal state
		in_ChangePC,
		in_MEMChangePC
		);// nnARM Instruction

//-----------------------------------------------------------//
//                      INPUTS                               //
//-----------------------------------------------------------//
input	[`AddressBusWidth-1:0]	in_AddressGoWithInstruction;
input [15:0] cti                         ;
input        clock                       ;
input        reset                       ;
input	in_ChangePC,in_MEMChangePC;

//-----------------------------------------------------------//
//                      OUTPUTS                              //
//-----------------------------------------------------------//
output	[`AddressBusWidth-1:0]	out_AddressOfFirstHalf;
output		out_ClearBit1;	//ssy add 2001 7 19
output [31:0] arm_inst                   ;

//-----------------------------------------------------------//
//                    REGISTERS & WIRES                      //
//-----------------------------------------------------------//

reg	ClearBit1;		//ssy add 2001 7 19
reg  [27:0] t2a                          ;
reg  [3:0]  cond                         ;
reg         wb_check                     ;


wire [1:0]  op0                          ;
wire        op1                          ;
wire        l_bit                        ;
wire        select_bit                   ;


//long branch with link state
//ssy add 2001 7 20
reg	[10:0]	LongBranchWithLinkOff;
//next state of LongBranchWithLinkOff
reg	[10:0]	Next_LongBranchWithLinkOff;

reg	[`AddressBusWidth-1:0]	AddressOfFirstHalf;
reg	[`AddressBusWidth-1:0]	Next_AddressOfFirstHalf;

assign	out_ClearBit1=ClearBit1;	//ssy add 2001 7 19
assign	out_AddressOfFirstHalf=AddressOfFirstHalf;

//-----------------------------------------------------------//
//                          CONDITION                        // 
//-----------------------------------------------------------//

always@(cti) //if async block is required 
/*always@(posedge clock or negedge reset) //if sync block is required                    
 if(reset)
  cond <= 4'b0000                                         ;

 else */ if(cti[15:12] == 4'b1101)  //Conditional Branches
    begin
      if(cti[11:8] == 4'b1111)	//SSY NOTE: SWI instruction
         cond <= 4'b1110                                  ;
      else if(cti[11:8] == 4'b1110)	//SSY NOTE: never be use
         cond <= 4'b1111                                  ;
      else
         cond <= cti[11:8]                                ; 
    end

                    //+++++++++++++++++++++//

  else if((cti[15:13] == 3'b010) & (~(| cti[12:11]) & cti[10]) ) //format 5.5 SSY NOTE:Hi reg operation or BX
     begin
       if(cti[9] & cti[8])	//SSY NOTE:BX
         cond <= {3'b111,cti[7]} 			                         ;//SSY NOTE: in this case cti[7] is always 1'b0,means ALWAYS run this instruction
       else			//SSY NOTE:Hi reg operation
         cond <= {3'b111,( ~( cti[7] | cti[6] ))}         ;	// SSY NOTE:~(cti[6] | cti[7]) is always 0, so ALWAYS Run
     end
  
                    //+++++++++++++++++++++//
  else
    cond <= 4'b1110                                       ; //ALWAYS


                    

//-----------------------------------------------------------//
//                          OpCode                           // 
//-----------------------------------------------------------//

assign op0        = ~( cti[12:11]       )                 ;
assign op1        = ~( cti[12] | cti[11])                 ;//SSY NOTE: 12 and 11 is 00
assign l_bit      =  ( cti[11] | cti[10])                 ;//SSY NOTE: 11 and 10 is 11 10 01 means load when cti is a compressed load/store sign data
assign select_bit =  (~l_bit   | cti[11])                 ;//SSY NOTE  11 and 10 is 00 10 11

always@(cti) //for multiple load write back only when base is
             //not in list
             //changed in ver 0.2
   begin
      case(cti[10:8])
          3'b000 : wb_check <= ~cti[0];
          3'b001 : wb_check <= ~cti[1];
          3'b010 : wb_check <= ~cti[2];
          3'b011 : wb_check <= ~cti[3];
          3'b100 : wb_check <= ~cti[4];
          3'b101 : wb_check <= ~cti[5];
          3'b110 : wb_check <= ~cti[6];
          3'b111 : wb_check <= ~cti[7];
          endcase
   end




always@(cti or op0 or op1 or l_bit or select_bit or wb_check) //if async block
/*always@(posedge clock or negedge reset) //if sync block
if(reset)
   t2a <= 28'b0;                                          ;

else */
begin
   
   //to prevent latch infer
   ClearBit1=1'b0;	//ssy add 2001 7 19
   Next_LongBranchWithLinkOff=11'b0000_0000_000;//ssy add 2001 7 20
   Next_AddressOfFirstHalf=`AddressBusZero;//ssy add 2001 7 20
   
   case(cti[15:13])

   3'b000  : begin    

		if(cti[12] & cti[11]) //Add/Subtract	

		t2a <= {2'b00,		//ARM data processing instruction [27:26] is always 00
			cti[10],		//Immediate value
			1'b0,~cti[9],cti[9],1'b0,//opcode 0010 is sub , 0100 is add
			1'b1,			//set condition code
			1'b0,cti[5:3],		//Rn -- first operand
			1'b0,cti[2:0],		//Rd -- second operand
			9'b000000000,cti[8:6]};	//3 bits extend to 12 bit offset

		else  //Move Shifted Register

		t2a <= {2'b00,			//ARM data processing instruction [27:26] is always 00
			1'b0,			//op2 is from register
			4'b1101,		//mov 
			1'b1,			//set condition code
			4'b0000, 		//op1 that do not use here
			1'b0,cti[2:0],		//destination register
			cti[10:6],		//shift ammount
			cti[12:11],		//shift type
			1'b0,			//no use here
			1'b0,cti[5:3]};		//the op2
		end
  
                    //+++++++++++++++++++++//

   3'b001  : begin   //Move/Compare/Add/Subtract immediate  
               case(cti[12:11])
		//move
                2'b00 : t2a <= {2'b00,		//ARM data processing instruction [27:26] is always 00
                		1'b1,		//immediate value
                		op0,cti[11],op1,//1101 is mov
                		1'b1,		//set condition code
                               4'b0000,		//op1 do not use here
                               1'b0,cti[10:8],	//target register
                               4'b0000,cti[7:0]};//extend  8bit imm to 12 bits
		//cmp
                2'b01 : t2a <= {2'b00,		//ARM data processing instruction [27:26] is always 00
                		1'b1,		//immediate value
                		op0,cti[11],op1,//1010 is cmp
                		1'b1,		//set condition code
                           	1'b0,cti[10:8],	//op1
                           	4'b0000,	//no target
                           	4'b0000,cti[7:0]};//extend  8bit imm to 12 bits
		//add
                2'b10 : t2a <= {2'b00,		//ARM data processing instruction [27:26] is always 00
                		1'b1,		//immediate value
                		op0,cti[11],op1,//0100 is add
                		1'b1,		//set condition code
                    		1'b0,cti[10:8],	//op1
                    		1'b0,cti[10:8],	//target register
                    		4'b0000,cti[7:0]};//extend 8 bits to 12 bits 
		//sub
                2'b11 : t2a <= {2'b00,		//ARM data processing instruction [27:26] is always 00
                		1'b1,		//immediate value
                		op0,cti[11],op1,//0010 is sub
                		1'b1,		//set condition code
                    		1'b0,cti[10:8],	//op1
                    		1'b0,cti[10:8],	//target register
                    		4'b0000,cti[7:0]};//extend 8 bits imm to 12 bits

               endcase
             end
  
                    //+++++++++++++++++++++//

   3'b010  : begin
              if(cti[12]==1'b1)

               begin
                if(cti[9]==1'b1)  // Load/Store sign-extended byte/halfword  

                  t2a <= {3'b000,	//half word and sign data transfer always have [27:25] as 000
                  	1'b1,		//pre index, add/sub offset and then transfer
                  	1'b1,		//add offset to base
                  	1'b0,		//no use here, always is 1'b0
                  	1'b0,		//do not write back address
                  	l_bit,		//1 means load,else store
                  	1'b0,cti[5:3],	//base register
                  	1'b0,cti[2:0],	//target register
			5'b00001,	//no use here, always is this value
			cti[10],	//S bit
			select_bit,	//excellent code about H and S bit ,Mian: the code reqired is (~cti[10] | cti[11]).
			1'b1,		//always this value
			1'b0,cti[8:6]};	//offset register

                else        //Load/Store with Register Offset   

                  t2a <= {2'b01,	//always 01
                  	1'b1,		//offset is a register
                  	1'b1,		//pre index
                  	1'b1,		//up , add offset to base
                  	cti[10],	//byte or word
                  	1'b0,		// do not need write back
                  	cti[11],	//load
                  	1'b0,cti[5:3],	//base register
			1'b0,cti[2:0],	//target register
			8'h00,		//no use here
			1'b0,cti[8:6]}; 	//offset register
               end 
          
                            //\/\/\/\/\/\/\\

              else if(cti[11]==1'b1) // PC-Relative Load    
              begin
                 t2a <= {2'b01,		//always 01	
                 	1'b0,		//offset is immediate value
                 	1'b1,		//pre index
                 	1'b1,		//up, add offset to base
                 	1'b0,		//transfer word
                 	1'b0,		//do not need write back
                 	1'b1,		//load
                 	4'b1111,	//PC use as base
                 	1'b0,cti[10:8],	//target register
                 	2'b00,cti[7:0],2'b00};//offset extend to 
                 	
                 ClearBit1=1'b1;	//ssy add 2001 7 19
              end
          
                            //\/\/\/\/\/\/\\

              else if(cti[10]==1'b1) // Hi Register Operations/Branch Exchange    
                 case(cti[9:8])
                 	//add
                   2'b00 : t2a <= {2'b00,		//always 00
                   		1'b0,			//op2 is a register
                   		4'b0100,		//add op
                   		1'b0,			//do not set condition code
                   		cti[7],cti[2:0],	//op1 and target
                   		cti[7],cti[2:0],	//op1 and target
                   		8'b00000000,		//just extend
                   		cti[6],cti[5:3]};	//op2 
			//cmp
                   2'b01 : t2a <= {2'b00,		//always 00
                   		1'b0,			//op2 is a register
                   		4'b1010,		//cmp op
                   		1'b1,			//set condition code
                   		cti[7],cti[2:0],	//op1
                   		4'h0,			//no target
				8'h00,			//just extend
				cti[6],cti[5:3]};	//op2
			//mov
                   2'b10 : t2a <= {2'b00,		//always 00
                   		1'b0,			//op2 is register
                   		4'b1101,		//mov
                   		1'b0,			// do not set condition code
                   		4'b0000,		//no op1
                   		cti[7],cti[2:0],	//target 
                   		8'b00000000,		//just extend
                   		cti[6],cti[5:3]};	//op2 to move to target
			//bx
                   2'b11 : t2a <= {20'b0001_0010_1111_1111_1111,
                                     4'b0001,cti[6],cti[5:3]};
                 endcase
          
                            //\/\/\/\/\/\/\\

              else             //ALU Operations
               case(cti[9:6])
               	//lsl
                4'b0010 : t2a <= {13'b000_1101_1_0000_0,cti[2:0],1'b0 ,	//mov lsl
                              cti[5:3],1'b0,cti[8],cti[6],2'b10,cti[2:0]};
                //lsr
                4'b0011 : t2a <= {13'b000_1101_1_0000_0,cti[2:0],1'b0 ,	//mov lsr
                              cti[5:3],1'b0,cti[8],cti[6],2'b10,cti[2:0]};
                //asr
                4'b0100 : t2a <= {13'b000_1101_1_0000_0,cti[2:0],1'b0 ,	//mov asr
                              cti[5:3],1'b0,cti[8],cti[6],2'b10,cti[2:0]};
                //ror
                4'b0111 : t2a <= {13'b000_1101_1_0000_0,cti[2:0],1'b	0 ,	//mov ror
                              cti[5:3],1'b0,cti[8],cti[6],2'b10,cti[2:0]};
                //tst
                4'b1000 : t2a <= {9'b000_1000_1_0,cti[2:0],4'b0000    ,
                              9'b000000000,cti[5:3]                     };
                //neg
                4'b1001 : t2a <= {9'b001_0011_1_0,cti[5:3],1'b0       ,
                              cti[2:0],12'h000                          };
                //cmp
                4'b1010 : t2a <= {9'b000_1010_1_0,cti[2:0],4'b0000    ,	
                              9'b000000000,cti[5:3]                     };
                //cmn
                4'b1011 : t2a <= {9'b000_1011_1_0,cti[2:0],4'b0000    ,
                              9'b000000000,cti[5:3]                     };
                //mul
                4'b1101 : t2a <= {9'b000_0000_1_0,cti[2:0],5'b00000   ,
                              cti[2:0],5'b10010,cti[5:3]                };
                //mvn	
                4'b1111 : t2a <= {13'b000_1111_1_0000_0,cti[2:0]      ,
                     	         9'b00000000_0,cti[5:3]                    };
                //op code same as normal arm instruction
                default : t2a <= {3'b000,cti[9:6],2'b10,cti[2:0],1'b0 ,	
                              cti[2:0],9'b000000000,cti[5:3]            }; //Mian: AND,EOR,ADC,SBC,ORR,BIC
               endcase
            end 

                    //+++++++++++++++++++++//

   3'b011  : begin      // Load/Store with Immediate Offset    
             if(cti[12]==1'b1) //transfer byte
                t2a <= {2'b01,				//always 01
                	1'b0,				//offset is immediate
                	1'b1,				//pre index
                	1'b1,				//up , add offset to base
                	cti[12],			//byte or word
                	1'b0,				//no write back
                	cti[11],			//load or store
                	1'b0,cti[5:3]   ,		//base register
                        1'b0,cti[2:0],			//store source or load target
                        5'b00000,2'b00,cti[10:6]}; 	//offset
             else		//transfer word
                t2a <= {5'b01011,cti[12],1'b0,cti[11],1'b0,cti[5:3]   ,
                        1'b0,cti[2:0],5'b00000,cti[10:6],2'b00          };//same as byte access, but must shift offset left 2 bit because word align
             end

                    //+++++++++++++++++++++//

   3'b100  : begin  
              if(cti[12]==1'b0)  //SP-relative Load/Store 

                t2a <= {2'b01,			//always 01
                	1'b0,			//offset is immediate
                	1'b1,			//pre index
                	1'b1,			//up add offset
                	1'b0,			//word transfer
                	1'b0,			//no write back
                	cti[11],		//load or store
                	4'b1101,		//base is R13(SP)
                	1'b0,cti[10:8],		//store source or load target
                        2'b00,cti[7:0],2'b00};	//word offset
              else //Load/Store Halfword

                t2a <= {3'b000,			//always 000
                	2'b11,			//pre index and up add offset
                	1'b1,			//always 1
                	1'b0,			//no write back
                	cti[11],		//load or store
                	1'b0,cti[5:3],		//base register
                	1'b0,cti[2:0],		//store source or load target
                	2'b00,cti[10:9],	//high 4 bit of offset
                	4'b1011,		//unsigned half word
                	cti[8:6],1'b0  };	//low 4 bit of offset
             end

                    //+++++++++++++++++++++//

   3'b101  : begin          
              if(cti[12]==1'b1) 

                begin 
                  if(cti[10]==1'b1) //Push/Pop Registers 
                  
                   t2a <= {3'b100,		//multiple register transfer
                          (~cti[11]),	//when load(1) post index, store(0) pre index
                          cti[11],	//when load(1) up,when store(0) down
                          1'b0,		//do not load PSR
                          1'b1,		//write back
                          cti[11],	//load or store
			  4'b1101,	//base is SP
			  (cti[11] & cti[8]), //when load  PC is loaded from MEM depending upon PC/LR bit (cti[8])
                          (~cti[11] & cti[8]),//when Store LR is stored to   MEM depending upon PC/LR bit (cti[8])
			  6'b000000,cti[7:0]};
                  
                  
//changed in ver 0.2
/*
                    begin
                      if(cti[11]==1'b1)	//ldm
                        t2a <= {3'b100,		//multiple register transfer
                        	(~cti[11]),	//when load(1) post index, store(0) pre index
                        	cti[11],	//when load(1) up,when store(0) down
                        	1'b0,		//do not load PSR
                        	1'b1,		//write back
                        	cti[11],	//load or store
				4'b1101,	//base is SP
				cti[8],1'b0,6'b000000,cti[7:0]}; //if load top stack to PC?
                      else		//stm
                        t2a <= {3'b100,		//always 100 for multiple register transfer
                        	(~cti[11]),
                        	cti[11],
                        	2'b01,
                        	cti[11],
				4'b1101,
				1'b0,cti[8], 6'b000000,cti[7:0]}; //store as LR?
                    end
*/

                  else //Add Offset to Stack Pointer
                    t2a <= {2'b00,		//always 00 for data processing
                    		1'b1,		//offset is immediate
                    		1'b0,(~cti[7]),cti[7],1'b0,//add or sub
				1'b0,			//do not set condition code
				4'b1101,		//op1 is SP
				4'b1101,		//target is SP
				4'b1111,		//ror 30 bit equal to lsl 2 bit
				1'b0,cti[6:0]};		//offset
                end

              else //Load Address
              begin
                t2a <= {2'b00,			//always 00
                	1'b1,			// immediate
                	4'b0100,		//add op
                	1'b0,			//do not set condition code
                	2'b11,(~cti[11]),1'b1,	//PC or SP
                	1'b0,cti[10:8],		//target register
                        4'b1111,cti[7:0]}; 	//ror 30 bit equal to lsl 2 bit
                ClearBit1=1'b1;		//ssy add 2001 7 19
              end
            end

                    //+++++++++++++++++++++//

   3'b110  : begin         
              if(cti[12]==1'b1) 

                  begin
                   if(& cti[11:8]) //SWI
                     t2a <= {4'b1111,16'h0000,cti[7:0]    }     ;
                   else            //Conditional Branch
                     t2a <= {4'b1010,{16{cti[7]}},cti[7:0]}     ;// ? {15{cti[7]}},cti[7:1]
                                                                 //Mian: This is not true conversion to ARM. Because in 
                                                                 //ARM branches are Word Aligned i.e [1:0] == 00
                                                                 //But in Thumb branches are Halfword aligned i.e [0] == 0 
                                                                 //So when Branch inst executes in Thumb, use (offset << 1), instead
                                                                 //(offset << 2) as in ARM state.
                  end

              else
                  begin
                    if(cti[11]==1'b1) //Multiple Load 
                                      //changed in ver 0.2
                       t2a <= {6'b100010,wb_check,cti[11],1'b0 ,
                                    cti[10:8],8'h00,cti[7:0]        };//only when the base is not in the list, can you write back that register

//wb_check replaced following case changed in ver 0.2
/*
                     case(cti[10:8])
                      3'b000 : t2a <= {6'b100010,~cti[0],cti[11],1'b0 ,
                                       cti[10:8],8'h00,cti[7:0]        };
                      3'b001 : t2a <= {6'b100010,~cti[1],cti[11],1'b0 ,
                                       cti[10:8],8'h00,cti[7:0]        };
                      3'b010 : t2a <= {6'b100010,~cti[2],cti[11],1'b0 ,
                                       cti[10:8],8'h00,cti[7:0]        };
                      3'b011 : t2a <= {6'b100010,~cti[3],cti[11],1'b0 ,
                                       cti[10:8],8'h00,cti[7:0]        };
                      3'b100 : t2a <= {6'b100010,~cti[4],cti[11],1'b0 ,
                                       cti[10:8],8'h00,cti[7:0]        };
                      3'b101 : t2a <= {6'b100010,~cti[5],cti[11],1'b0 ,
                                       cti[10:8],8'h00,cti[7:0]        };
                      3'b110 : t2a <= {6'b100010,~cti[6],cti[11],1'b0 ,
                                       cti[10:8],8'h00,cti[7:0]        };
                      3'b111 : t2a <= {6'b100010,~cti[7],cti[11],1'b0 ,
                                       cti[10:8],8'h00,cti[7:0]        };
                     endcase
*/

                    else  //Multiple Store
                      t2a <= {6'b100010,1'b1,cti[11],1'b0,
                                   cti[10:8],8'h00,cti[7:0]};
                  end
               end
               
                    //+++++++++++++++++++++//


   3'b111  : begin   
              if(cti[12]==1'b1) //Long Branch =  NO Operation 
              begin
              	if(cti[11]==1'b0)	//the high 11 bits of offset
              	begin
                 t2a <= {28'b000_1101_0_0000_0000_00000_00_0_0000}; 
                                          //MOV r0,r0 i.e No Operation
                 Next_LongBranchWithLinkOff=cti[10:0];
                 Next_AddressOfFirstHalf={in_AddressGoWithInstruction[`AddressBusWidth-1:1],1'b1};	//indicate there is a valid long branch with link
                end
                else
                begin
                 t2a <= {4'b1011,2'b00,LongBranchWithLinkOff,cti[10:0]};//generate a bl with two 11bits offset, you must shift left 1 bit (not 2 bit as normal bl)to get real offset
                 Next_LongBranchWithLinkOff=LongBranchWithLinkOff;	//preserve the high bits because the later stage may not being able to go
                 Next_AddressOfFirstHalf=AddressOfFirstHalf;
                end
              end
              else //UnConditional Branch	
                 t2a <= {4'b1010,{13{cti[10]}},cti[10:0]} ;//?
                                                           //Mian: This is not true conversion to ARM. Because in 
                                                           //ARM branches are Word Aligned i.e [1:0] == 00
                                                           //But in Thumb branches are Halfword aligned i.e [0] == 0 
                                                           //So when Branch inst executes in Thumb, use (offset << 1), instead
                                                           //(offset << 2) as in ARM state.  
              end
               
                    //+++++++++++++++++++++//

   default : t2a <= {28'b000_1101_0_0000_0000_00000_00_0_0000}; //MOV R0,R0 


 endcase
	if(in_ChangePC==1'b1 || in_MEMChangePC==1'b1)
	begin
		Next_LongBranchWithLinkOff=11'b0000_0000_000;
		Next_AddressOfFirstHalf=`AddressBusZero;
	end
end
//-----------------------------------------------------------//
//                Joining The Condition and Opcode           // 
//-----------------------------------------------------------//

  assign arm_inst = {cond,t2a} ;

//ssy add 2001 7 20
always	@(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		LongBranchWithLinkOff=11'b0000_0000_000;
		AddressOfFirstHalf=`AddressBusZero;
	end
	else
	begin
		LongBranchWithLinkOff=Next_LongBranchWithLinkOff;
		AddressOfFirstHalf=Next_AddressOfFirstHalf;
	end
end

endmodule
