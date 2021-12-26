function Invoke-CMakeHeader() {
	if ($null -eq $ENV:C) {
		$ENV:C = "clang"		# Set the default C compiler to clang, if it's not set already
	}	
	if (-not (Test-Path -Path "CMakeLists.txt")) {
		Write-Error "CmakeLists.txt not found!"
		return;
	}

	Write-Host "==========";
	$c_compiler_version = "($ENV:C --version)[0]";
	Write-Host "$(Invoke-Expression $c_compiler_version)";
	Write-Host "$(Invoke-Expression '(cmake --version)[0]')";
	$projectName = (Get-ChildItem CMakeLists.txt) | Select-String 'PROJECT_NAME\s"(.+)"'
	Write-Host "Project: $($projectName.Matches.Groups[1].Value)"
	Write-Host "==========";
}
function Invoke-CMakeBuild {
	param ( 
		[Parameter()]
		[ValidateSet("UNIX", "MSVC")]
		[string]	$BuildTarget = "UNIX",
		[Parameter()]
		[string]	$CmakeArgs = "", 
		[Parameter()]
		[ValidateSet("WARNING", "NORMAL", "DEBUG")]
		[string]	$LogLevel = "Normal",
		[Parameter()]
		[switch] 	$SkipPreMake
		# [Parameter()]
		# [ValidateSet("Release", "Debug")]
		# [string]	$Config = "Debug"
	)
	$config = "debug"
	# Add Generator
	if ($BuildTarget -eq "UNIX") {
		$CmakeArgs = "$CmakeArgs -G'Unix Makefiles'"
	}
	else{
		Write-Error "MSVC not supported yet."	#TODO: Add suport for MSVC
	}
	# Add LogLevel
	if ($LogLevel -ne "NORMAL") {
		$CmakeArgs = "$CmakeArgs --log-level $LogLevel"
	}

	# $CmakeArgs = "$CmakeArgs --preset $Config"
	if (-not $SkipPreMake){
		Write-Host "Cleaning output folders"
		Invoke-Expression "rm -Recurse -Force bin/d*, include/d*, lib/*"
		if (Test-Path -Path build){
			Invoke-Expression "rm -Recurse -Force build"
		}

		Write-Host "Creating Build folder..."
		Invoke-Expression "mkdir -p build/$config"	#TODO: Add support for config
		Invoke-Expression "git submodule init; git submodule update"
	}

	Write-Host "Building..."
	Invoke-Expression "cd build/$config"

	if ($LogLevel -ne "Warning"){
		Invoke-Expression "cmake $CmakeArgs ../.." | Tee-Object -FilePath .\.log
		Invoke-Expression "make -j $((Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors / 2)" | Tee-Object -FilePath .log
		Invoke-Expression "make install" | Tee-Object -FilePath .log
	}
	else {
		Invoke-Expression "cmake $CmakeArgs ../.." | Out-Null
		Invoke-Expression "make -j $((Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors / 2)" | Out-Null
		Invoke-Expression "make install" | Out-Null
	}
	
	Move-Item -Force compile_commands.json ../..
	Invoke-Expression "cd ../.."
}
function Invoke-CMakeTests() {
	$test_executables = fd -u -e "exe" "Test" ./bin
	if ($test_executables.Length -gt 0) {
		foreach ($testSuite in $test_executables) {
			Invoke-Expression $testSuite
		}
	}
	else {
		Write-Warning "No TestSuite found in ./bin"
	}
}

function Invoke-Cmake {
	param ( 
		[Parameter()]
		[ValidateSet("UNIX", "MSVC")]
		[string]	$BuildTarget = "UNIX",
		[Parameter()]
		[string]	$CmakeArgs = "", 
		[Parameter()]
		[ValidateSet("WARNING", "NORMAL", "DEBUG")]
		[string]	$LogLevel = "Normal"
	)
	Invoke-CMakeHeader;
	if (-not $?) { return; }
	Invoke-CMakeBuild -BuildTarget $BuildTarget -CmakeArgs $CmakeArgs -LogLevel $LogLevel;
	if (-not $?) { return; }
	Invoke-CMakeTests;
}
