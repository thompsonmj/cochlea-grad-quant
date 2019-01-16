//imgStack = File.openDialog("Select an image file.");
wait(1000)
Stack.getDimensions(width, height, channels, slices, frames);
IBNROIFilePath = File.openDialog("Select an Instrument Background Noise ROI file.");
SBNROIFilePath = File.openDialog("Select a Sample Background Noise ROI file.");
savePath = File.openDialog("Select a directory to save ROI results.");
for (iSlice = 1; iSlice <= slices; iSlice++) {
	Stack.setSlice(iSlice);

	// Handle instrument background noise.
	roiManager("Open", IBNROIFilePath);
	roiManager("Show All");
	nROIs = roiManager("count");
	roiManager("Measure");
	run("Summarize");
	//saveAs("Results", "D:/data/cochlea_images/by_matt/20180430_SW15_E12.5_1B - DAPI-pSmad_488-Sox2_561-TOPRO/tif/processed/5.10/IBNResults"+iSlice+".csv");
	savePathIBN = ""+savePath+"/IBNResults"+iSlice+".csv";
	saveAs("Results",savePathIBN);
	meanROIIntensity = getResult("Mean",nROIs);
	run("Close");
	print(meanROIIntensity);
	roiManager("Delete");
	run("Close");
	run("Subtract...", "value=&meanROIIntensity slice");

	// Handle sample background noise.
	roiManager("Open", SBNROIFilePath);
	roiManager("Show All");
	nROIs = roiManager("count");
	roiManager("Measure");
	run("Summarize");
	saveAs("Results", "D:/data/cochlea_images/by_matt/20180430_SW15_E12.5_1B - DAPI-pSmad_488-Sox2_561-TOPRO/tif/processed/5.10/SBNResults"+iSlice+".csv");
	savePathSBN = ""+savePath+"/SBNResults"+iSlice+".csv";
	saveAs("Results",savePathSBN);
	meanROIIntensity = getResult("Mean",nROIs);
	run("Close");
	print(meanROIIntensity);
	roiManager("Delete");
	run("Close");
	run("Subtract...", "value=&meanROIIntensity slice");
}
