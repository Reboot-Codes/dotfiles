{
  allowUnfree = true;

	nvidia.acceptLicense = true;

  permittedInsecurePackages = [
    "electron-25.9.0"
    "electron-27.3.11"
    "olm-3.2.16"
    "dotnet-sdk-7.0.120"
		"SDL_ttf-2.0.11"
  ];

  packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
}
