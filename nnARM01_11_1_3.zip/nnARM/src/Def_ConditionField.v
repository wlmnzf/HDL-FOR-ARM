//////////////////////////////////////////////////////////////////////////
//			condition code definition			//
//									//
//  this file define the condition code of arm7 instructions,it is 	//
//reside in the [31:28] bits of every instruction,whether this 		//
//instruction will be execute depende on the condition field		//
//									//
//									//
//author:ShengYu Shen of national university of defense technology	//
//create time: 2001 3 16						//
//reference:ARM7vC.pdf from www.arm.com					//
//////////////////////////////////////////////////////////////////////////



`define ConditionField_EQ	4'b0000		//Z set(equal)
`define ConditionField_NE	4'b0001		//Z clear(not equal)
`define ConditionField_CS	4'b0010		//C set(unsigned higher or same)
`define ConditionField_CC	4'b0011		//C clear(unsigned lower)
`define ConditionField_MI	4'b0100		//N set(negative)
`define ConditionField_PL	4'b0101		//N clear(positive or zero)
`define ConditionField_VS	4'b0110		//V set(overflow)
`define ConditionField_VC	4'b0111		//V clear(no overflow)
`define ConditionField_HI	4'b1000		//C set and Z clear(unsigned higher,see ConditionField_CS)
`define ConditionField_LS	4'b1001		//C clear or Z set(unsigned lower or same see ConditionField_CC)
`define ConditionField_GE	4'b1010		//N set and V set, or N clear and V clear(greater or equal)
`define ConditionField_LT	4'b1011		//N set and V clear,or N clear and V set(less than)
`define ConditionField_GT	4'b1100		//Z clear, and either N set and V set, or N clear and V clear (greater than)
`define ConditionField_LE	4'b1101		//Z set, or N set and V clear, or N clear and V set (less than or equal)
`define ConditionField_AL	4'b1110		//always execute
`define ConditionField_NV	4'b1111		//never execute
