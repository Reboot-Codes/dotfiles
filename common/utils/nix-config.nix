{
  allowUnfree = true;

	nvidia.acceptLicense = true;

  permittedInsecurePackages = [
    "ladybird-0-unstable-2026-06-05"
		"electron-39.8.10"
    "olm-3.2.16"
    "dotnet-sdk-7.0.120"
		"SDL_ttf-2.0.11"
		"ventoy-1.1.17"
		"gradle-7.6.6"
  ];

  packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
}
