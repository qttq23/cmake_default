
cmake -P run.cmake || goto :error

echo build successfully && exit /b

:error
echo Failed with error %errorlevel%.
exit /b %errorlevel%
