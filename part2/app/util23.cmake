
## deprecated
# function(get_version_from_file
# 	_fileName _beginPlaceHolder _endPlaceHolder _outputVersionString)
	
# 	set(logLevel "DEBUG")
# 	if(ARGC GREATER 4 AND ARGV4 AND NOT ARGV4 EQUAL "")
# 		set(logLevel ${ARGV4})
# 	endif()

#     file(READ "${_fileName}" VERSION_H_CONTENT)
#     string(FIND "${VERSION_H_CONTENT}" ${_beginPlaceHolder} INDEX_VERSION_BEGIN)
#     if(INDEX_VERSION_BEGIN EQUAL -1)
#         message(ERROR "fail to get VERSION_BEGIN from file")
#         return()
#     endif()
#     message(${logLevel} "INDEX_VERSION_BEGIN: ${INDEX_VERSION_BEGIN}")

#     string(FIND "${VERSION_H_CONTENT}" ${_endPlaceHolder} INDEX_VERSION_END)
#     if(INDEX_VERSION_END EQUAL -1)
#         message(ERROR "fail to get VERSION_END from file")
#         return()
#     endif()
#     message(${logLevel} "INDEX_VERSION_END: ${INDEX_VERSION_END}")

#     string(LENGTH ${_beginPlaceHolder} temp_beginPlaceHolderLength)
#     message(${logLevel} "temp_length: ${temp_length}")

#     math(EXPR temp_begin "${INDEX_VERSION_BEGIN} + ${temp_beginPlaceHolderLength}" 
#             OUTPUT_FORMAT DECIMAL)  
#     message(${logLevel} "temp_begin: ${temp_begin}")

#     math(EXPR temp_length "${INDEX_VERSION_END} - ${temp_begin}" OUTPUT_FORMAT DECIMAL)
#     message(${logLevel} "temp_length: ${temp_length}")

#     string(SUBSTRING "${VERSION_H_CONTENT}" ${temp_begin} ${temp_length} VERSION_OUTPUT)
#     message(${logLevel} "VERSION_OUTPUT: ${VERSION_OUTPUT}")

#     set(${_outputVersionString} "${VERSION_OUTPUT}" PARENT_SCOPE)
# endfunction()



# eg:
# get_version_from_file("../dll2/src/dll2/version.h"
#     "DLL2_VERSION[ \t]+\"([^/ \t\n\r]+)\"[/ \t\n\r]*"
#     out_version
#     DEBUG)
# message(STATUS "ver: ${out_version}")
#
function(get_version_from_file
    _fileName _regex _outputVersionString _logLevel)
    
    # read & find
    file(READ "${_fileName}" VERSION_H_CONTENT)
    string(REGEX MATCH 
        "${_regex}"
        temp1 "${VERSION_H_CONTENT}")
    message(${_logLevel} "VERSION_H_CONTENT: ${VERSION_H_CONTENT}")
    message(${_logLevel} "CMAKE_MATCH_COUNT: ${CMAKE_MATCH_COUNT}")
    message(${_logLevel} "CMAKE_MATCH_0: ${CMAKE_MATCH_0}")
    message(${_logLevel} "CMAKE_MATCH_1: ${CMAKE_MATCH_1}")

    # output
    set(${_outputVersionString} "${CMAKE_MATCH_1}" PARENT_SCOPE)
endfunction()



# eg:
# set(input_list "A;B;C;D;E;F;G;H;I;K")
# set(A_list "E;F;K")
# set(E_list "H;I;D;K")
# sort_dependencies(input_list output_list DEBUG)
# message(STATUS "success sort_dependencies: ${output_list}")
#
function(sort_dependencies
    _input_list _output_list _logLevel)

    # copy input list
    set(input_list2 "${${_input_list}}")
    message(${_logLevel} "input_list2: ${input_list2}")

    # loop
    list(LENGTH input_list2 length)
    while(length GREATER 0)

        list(LENGTH input_list2 length)
        message(${_logLevel} "length: ${length}")
        while(length GREATER 0)
            list(POP_FRONT input_list2 currentItem)
            message(${_logLevel} "currentItem: ${currentItem}")

            if(${currentItem}_priority GREATER 0)
                message(${_logLevel} "_priority > 0. continue")
                break()

            elseif(NOT ${currentItem}_list)
                message(${_logLevel} "leap. set _priority = 1. continue")
                math(EXPR ${currentItem}_priority "1" OUTPUT_FORMAT DECIMAL) 
                break()

            else()
                message(${_logLevel} "not leap.")
                math(EXPR max_priority "0" OUTPUT_FORMAT DECIMAL) 
                set(is_continue OFF)

                foreach(child IN LISTS ${currentItem}_list)
                    message(${_logLevel} "child: ${child}")

                    if(NOT ${child}_priority)
                        message(${_logLevel} "child not resolved. queueing it")

                        list(APPEND input_list2 ${currentItem})
                        list(REMOVE_ITEM input_list2 ${child})
                        list(PREPEND input_list2 ${child})


                        # check if circular dependencies
                        if(NOT ${currentItem}_chain)
                            message(${_logLevel} "not have chain. assigning itself")
                            set(${currentItem}_chain "${currentItem}")
                        endif()
                        message(${_logLevel} "${currentItem} chain: ${${currentItem}_chain}")

                        list(FIND ${currentItem}_chain ${child} index1)
                        if(index1 LESS 0)
                            message(${_logLevel} "ok. not circular. appending child to its chain")
                            set(${child}_chain "${${currentItem}_chain}")
                            list(APPEND ${child}_chain "${child}")
                        else()  # >= 0
                            message(FATAL_ERROR "circular dependencies!!! failed!")
                            return()
                        endif()
                        # set(${child}_chain ${${currentItem}_chain})
                        
                        set(is_continue ON)
                        break()
                    else()
                        message(${_logLevel} "child already resolved.")
                        if(${child}_priority GREATER max_priority)
                            math(EXPR max_priority "${${child}_priority}" OUTPUT_FORMAT DECIMAL) 
                        endif()
                        message(${_logLevel} "max_priority: ${max_priority}")

                    endif()

                endforeach()

                if(is_continue)
                    message(${_logLevel} "is_continue: ${is_continue}")
                    break()
                else()
                    math(EXPR ${currentItem}_priority "${max_priority} + 1" OUTPUT_FORMAT DECIMAL) 
                    message(${_logLevel} "currentItem _priority: ${${currentItem}_priority}")
                    break()
                endif()
                
            endif()

        endwhile()
    
    endwhile()


    # sort
    set(input_list2 "${${_input_list}}")
    list(LENGTH input_list2 length)
    message(${_logLevel} "sorting list: ${length}")
    while(length GREATER 0)

        # get first elem
        list(GET input_list2 0 min_child)
        message(${_logLevel} "first elem: ${min_child}")

        # compare to other elems
        foreach(child IN LISTS input_list2)
            if(${child}_priority LESS ${min_child}_priority)
                message(${_logLevel} "found more min: ${child} : ${${child}_priority}")
                set(min_child ${child})
            endif()
        endforeach()

        # push to output array
        message(${_logLevel} "min_child: ${min_child} : ${${min_child}_priority}")
        list(APPEND output_list2 ${min_child})
        list(REMOVE_ITEM input_list2 ${min_child})

        # re-get length
        list(LENGTH input_list2 length)
        message(${_logLevel} "length of input_list2: ${length}")
    endwhile()


    list(LENGTH output_list2 length)
    message(${_logLevel} "length of output_list2: ${length}")
    set(${_output_list} ${output_list2} PARENT_SCOPE)

endfunction()