#ifndef INTEROP_H
#define INTEROP_H

WARNING // Warning about generated file - do not edit.


// --------------------------------------------------------------------------
// FUNC.DESCRIPTION
// @param name ARG_TYPE ARG_DESCRIPTION
// @return RET_TYPE RET_DESCRIPTION
void interop_Load(lua_State* l);

// --------------------------------------------------------------------------
// FUNC.DESCRIPTION
// @param name ARG_TYPE ARG_DESCRIPTION
// @return RET_TYPE RET_DESCRIPTION
RET_TYPE HOST_FUNC_NAME(ARG_TYPE_1 ARG_NAME_1, ARG_TYPE_2 ARG_NAME_2, ARG_TYPE_3 ARG_NAME_3, ...)

// --------------------------------------------------------------------------
// FUNC.DESCRIPTION
// @param name ARG_TYPE ARG_DESCRIPTION
// @return RET_TYPE RET_DESCRIPTION
RET_TYPE WORK_FUNC(ARG_NAME_1, ARG_NAME_2, ...);

#endif // INTEROP_H
