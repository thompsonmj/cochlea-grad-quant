// Removes background noise from one source at a time (Instrument bkgd or sample bkgd).
// To use:
// 0.1) For a stack containing a single channel, create an ROI file for the sampled background regions.
// 		Note: Each region's properties must have Position set to 0 individually, and name must exclude the slice number.
// 1) Once ROIs are created and saved, open the tif and run the macro.
// 		Note: this must be run for each type of background to subtract (ibn and if applicable sbn).
// 2) Select the corresponding ROI file to the sample and type of bkgd to be subtracted.
// 3) Save as <#>_ch<#>-<target>_bkgd-sub.tif

wait(250);
delay = 50;
Stack.getDimensions(width, height, channels, slices, frames);
ROIFilePath = File.openDialog("Select a Background Noise ROI file.");

for (iSlice = 1; iSlice <= slices; iSlice++) {
	wait(delay);
	Stack.setSlice(iSlice);

	// Handle background noise.
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
	wait(delay);
	roiManager("Delete");
	wait(delay);
	run("Close");
	wait(delay);
	run("Subtract...", "value=&meanROIIntensity slice");
}