//imgStack = File.openDialog("Select an image file.");
wait(250);
delay = 25;
Stack.getDimensions(width, height, channels, slices, frames);
ROIFilePath = File.openDialog("Select an INSTRUMENT Background Noise ROI file.");
//savePath = File.directory;
for (iSlice = 1; iSlice <= slices; iSlice++) {
	wait(delay);
	Stack.setSlice(iSlice);

	// Handle instrument background noise.
	wait(delay);
	roiManager("Open", ROIFilePath);
	wait(delay);
	roiManager("Show All");
	wait(delay);
	nROIs = roiManager("count");
	wait(delay);
	roiManager("Measure");
	wait(delay);
	run("Summarize");
	wait(delay);
	meanROIIntensity = getResult("Mean",nROIs);
	wait(delay);
	run("Close");
	//print(meanROIIntensity);
	wait(delay);
	roiManager("Delete");
	wait(delay);
	run("Close");
	wait(delay);
	run("Subtract...", "value=&meanROIIntensity slice");
}
