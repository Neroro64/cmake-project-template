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
		[string]	$LogLevel = "Normal"
		# [Parameter()]
		# [ValidateSet("Release", "Debug")]
		# [string]	$Config = "Debug"
	)

	# Add Generator
	if ($BuildTarget -eq "UNIX") {
		$CmakeArgs = "$CmakeArgs -G'Unix Makefiles'"
	}
	# Add LogLevel
	if ($LogLevel -ne "NORMAL") {
		$CmakeArgs = "$CmakeArgs --log-level $LogLevel"
	}
	# $CmakeArgs = "$CmakeArgs --preset $Config"

	Write-Host "Cleaning output folders"
	Invoke-Expression "rm -Recurse -Force bin/d*, include/d*, lib/*"
	if (Test-Path -Path build){
		Invoke-Expression "rm -Recurse -Force build"
	}

	Write-Host "Creating Build folder..."
	Invoke-Expression "mkdir -p build/run"
	Invoke-Expression "git submodule init; git submodule update"


	Write-Host "Building..."
	Invoke-Expression "cd build/run"

	Invoke-Expression "cmake $CmakeArgs ../.." -InformationVariable $build_cmake
	Invoke-Expression "make -j $((Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors / 2)" -InformationVariable $build_make
	Invoke-Expression "make install" -InformationVariable $build_makeInstall
	"$build_cmake `n $build_make `n $build_makeInstall" | Out-File -FilePath .log

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

function Invoke-Cmake() {
	Invoke-CMakeHeader;
	if (-not $?) { return; }
	Invoke-CMakeBuild;
	if (-not $?) { return; }
	Invoke-CMakeTests;
}
