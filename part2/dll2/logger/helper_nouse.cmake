
function(_logger_helper_install_header target _destination logLevel)

	message(${logLevel} "enter logger_helper_install_header")
	
	# is_export is custom property indicates that target is exported.
	# this differs from exported from build tree.
	get_target_property(is_export ${target} is_export)
	if(is_export)
		message(${logLevel} "${target}: isexport")

		get_target_property(basedirs ${target} header_basedirs)
		if(header_basedirs)
			foreach(dir IN LISTS basedirs)
				message(${logLevel} "${target}: dir: ${dir}")
				install(DIRECTORY "${dir}/" DESTINATION "${_destination}")
			endforeach()

		endif()

	else()
		message(${logLevel} "${target}: NOT is_export")

		get_target_property(basedirs ${target} header_basedirs)
		get_target_property(files ${target} header_files)
		if(header_basedirs AND header_files)
			message(${logLevel} "${target}: has header_basedirs AND header_files")

			# create custom target to file_set ??

			# or just using old plain string api
			foreach(file IN LISTS files)
				message(${logLevel} "${target}: ${file}")

				foreach(dir IN LISTS basedirs)

					string(FIND ${file} ${dir} pos)
					if(pos GREATER_EQUAL 0)
						message(${logLevel} "${target}: matched dir: ${dir}")

						string(LENGTH ${dir} length)
						string(SUBSTRING ${file} ${length} -1 relative_path)							
						get_filename_component(relative_path "${relative_path}" PATH)
						string(CONCAT destination_concated ${_destination} "/" ${relative_path})

						install(FILES ${file} DESTINATION ${destination_concated})

						message(${logLevel} "${target}: destination_concated: ${destination_concated}")
						break()

					endif()

				endforeach()

			endforeach()
		endif()



	endif()


endfunction()


function(_logger_helper_install_runtime target _destination logLevel)

	message(${logLevel} "enter logger_helper_runtime")

	# IMPORTED is standard property. it indicates that target is 
	# imported from third-party library or from build tree.
	get_target_property(is_import ${target} IMPORTED)
	if(is_import)
		message(${logLevel} "${target} is_import")
		install(IMPORTED_RUNTIME_ARTIFACTS ${target} DESTINATION ${_destination})

	else()
		message(${logLevel} "${target} NOT is_import")

		# if local, this target may be an alias which cannot be installed.
		set(real_name ${target})
		get_target_property(origin_name ${target} ALIASED_TARGET)
		if(origin_name)
			set(real_name ${origin_name})
		endif()
		message(${logLevel} "${target} real_name: ${real_name}")

		install(TARGETS ${real_name} RUNTIME DESTINATION ${_destination})

	endif()


endfunction()


# _type: runtime or header
# _destination: path relative to cmake_install_prefix
function(logger_helper_install
	_type _destination)

# loglevel
set(logLevel STATUS)
message(${logLevel} "enter logger_helper_install")

# get target name
set(target_name "dll2::Logger")
get_target_property(origin_name ${target_name} ALIASED_TARGET)
if(origin_name)
	set(target_name ${origin_name})
	message(${logLevel} "target_name: ${target_name}")
endif()

# call handler
string(COMPARE EQUAL ${_type} "header" is_header)
string(COMPARE EQUAL ${_type} "runtime" is_runtime)
if(is_header)
	_logger_helper_install_header(${target_name} ${_destination} ${logLevel})

elseif(is_runtime)
	_logger_helper_install_runtime(${target_name} ${_destination} ${logLevel})
endif()


# if logger depends on other targets
# call other targets script here ...

endfunction()


