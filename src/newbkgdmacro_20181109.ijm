wait(1000)
Stack.getDimensions(width, height, channels, slices, frames);
//IBNROIPATH = File.openDialog("Select an Instrument Background Noise ROI file.");
//SBNROIPATH = File.openDialog("Select a Sample Background Noise ROI file.");
//savePath = File.openDialog("Select a directory to save ROI results.");


for (iSlice = 1; iSlice <= slices; iSlice++) {
    Stack.setSlice(iSlice);
    roiManager("Open", IBNROIPATH);
    roiManager("Show All");
    nROIs = roiManager("count");
    run
}
run("Make Substack...", "delete slices=1");

