final: prev: {
	kdePackages = prev.kdePackages.overrideScope (kdeFinal: kdePrev: {
		kdenlive = kdePrev.kdenlive.overrideAttrs (kdenPrev: {
			buildInputs = kdenPrev.buildInputs ++ 
				[ prev.python3
					prev.python3Packages.pip
					prev.python3Packages.numpy
					prev.python3Packages.torch
					prev.python3Packages.srt
					prev.python3Packages.openai-whisper
				];
		});
	});
}
