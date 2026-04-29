// -------- USER SETTINGS --------
// Ensure this path exists on your machine
outputDir = "D:/R251G_IHC_20260115/IHC/APOE4/RSC/MAP2_OUTPUT/";
if (!File.exists(outputDir)) File.makeDirectory(outputDir);

thresholdMethod = "Triangle";
rollingBallRadius = 30;
medianRadius = 1;
reviewThreshold = true;
autoCreateTissueROI = true;

// -------- START --------
requires("1.53");
setBatchMode(false);

origTitle = getTitle();
baseName = stripExtension(origTitle);

greenTitle = "MAP2_green_raw";
workTitle = "MAP2_green_threshold_work";
maskTitle = "MAP2_green_mask";
maskedTitle = "MAP2_green_positive_intensity";

// Use the helper function to clear workspace [cite: 38]
closeIfOpen(maskedTitle);
closeIfOpen(maskTitle);
closeIfOpen(workTitle);
closeIfOpen(greenTitle);

// Create the 8-bit green channel image [cite: 5, 34]
makeGreenImage(origTitle, greenTitle);

// ROI Creation Logic [cite: 8, 10]
selectWindow(origTitle);
if (selectionType() != -1) {
    roiManager("Add");
    roiSource = "Current selection";
} else if (autoCreateTissueROI) {
    selectWindow(greenTitle);
    run("Duplicate...", "title=MAP2_tissue_roi_work");
    setThreshold(1, 255);
    setOption("BlackBackground", true);
    run("Convert to Mask");
    run("Fill Holes");
    run("Create Selection");
    if (selectionType() != -1) {
        roiManager("Add");
        roiSource = "Auto tissue ROI";
    } else {
        makeRectangle(0, 0, getWidth(), getHeight());
        roiManager("Add");
        roiSource = "Full image fallback";
    }
    closeIfOpen("MAP2_tissue_roi_work");
} else {
    makeRectangle(0, 0, getWidth(), getHeight());
    roiManager("Add");
    roiSource = "Full image";
}

roiIndex = roiManager("Count") - 1;

// Pre-processing and Thresholding [cite: 16, 17, 18]
selectWindow(greenTitle);
run("Duplicate...", "title=" + workTitle);
roiManager("Select", roiIndex);
run("Clear Outside");
if (rollingBallRadius > 0) run("Subtract Background...", "rolling=" + rollingBallRadius);
if (medianRadius > 0) run("Median...", "radius=" + medianRadius);

setAutoThreshold(thresholdMethod + " dark");
if (reviewThreshold) waitForUser("Review Threshold", "Adjust if needed, then click OK");

run("Convert to Mask");
rename(maskTitle);

// Quantification [cite: 21, 22, 25]
selectWindow(maskTitle);
roiManager("Select", roiIndex);
getStatistics(roiArea, maskMean);
positiveAreaPct = 100 * maskMean / 255;
positiveArea = roiArea * (maskMean / 255);

selectWindow(greenTitle);
roiManager("Select", roiIndex);
getStatistics(rawArea, rawMean);
rawIntegratedDensity = rawMean * rawArea;

// Measure Signal in Masked Area [cite: 24, 26]
selectWindow(maskTitle);
run("Create Selection");
if (selectionType() != -1) {
    roiManager("Add");
    posIdx = roiManager("Count") - 1;
    selectWindow(greenTitle);
    roiManager("Select", posIdx);
    getStatistics(pArea, pMean);
    pIntDen = pMean * pArea;
    
    run("Duplicate...", "title=" + maskedTitle);
    roiManager("Select", posIdx);
    run("Clear Outside");
} else {
    pMean = 0;
    pIntDen = 0;
    selectWindow(greenTitle);
    run("Duplicate...", "title=" + maskedTitle);
    run("Select All");
    run("Clear");
}

// Saving Results [cite: 28, 29, 30]
row = nResults;
setResult("Image", row, origTitle);
setResult("ROI_Area", row, roiArea);
setResult("MAP2_Positive_%Area", row, positiveAreaPct);
setResult("MAP2_Positive_IntDen", row, pIntDen);
updateResults();

saveAs("Results", outputDir + baseName + "_results.csv");
selectWindow(maskTitle);
saveAs("Tiff", outputDir + baseName + "_mask.tif");
selectWindow(maskedTitle);
saveAs("Tiff", outputDir + baseName + "_masked_signal.tif");

// Final Cleanup [cite: 32]
closeIfOpen(maskedTitle);
closeIfOpen(maskTitle);
closeIfOpen(greenTitle);
closeIfOpen(workTitle);

print("Processing complete: " + origTitle);

// -------- FUNCTIONS --------

function makeGreenImage(sourceTitle, targetTitle) {
    selectWindow(sourceTitle);
    run("Duplicate...", "title=" + targetTitle);
    if (bitDepth() == 24) {
        run("RGB Stack");
        setSlice(2); // Green channel 
        run("Internal Clipboard Copy");
        run("Internal Clipboard Paste");
        rename(targetTitle);
    } else {
        run("8-bit");
    }
    run("Grays");
}

function stripExtension(name) {
    return replace(name, ".tif", "");
}

function closeIfOpen(title) {
    if (isOpen(title)) {
        selectWindow(title);
        close();
    }
}