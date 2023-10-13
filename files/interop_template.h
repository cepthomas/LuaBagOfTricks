#ifndef INTEROP_H
#define INTEROP_H

// Warning - this is a generated file, do not edit.


// --------------------------------------------------------------------------
// func.DESCRIPTION
// @param ARG1_NAME ARG1_DESCRIPTION
// @param ...
// @return RET_TYPE RET_DESCRIPTION
void interop_Load(lua_State* l);

// --------------------------------------------------------------------------
// func.DESCRIPTION
// @param ARG1_NAME ARG1_DESCRIPTION
// @param ...
// @return RET_TYPE RET_DESCRIPTION
RET_TYPE HOST_FUNC_NAME(ARG1_TYPE ARG1_NAME, ARG2_TYPE ARG2_NAME, ARG3_TYPE ARG3_NAME, ...)

// --------------------------------------------------------------------------
// func.DESCRIPTION
// @param ARG1_NAME ARG1_DESCRIPTION
// @param ...
// @return RET_TYPE RET_DESCRIPTION
RET_TYPE WORK_FUNC(ARG1_TYPE ARG1_NAME, ARG2_TYPE ARG2_NAME, ...);

#endif // INTEROP_H
