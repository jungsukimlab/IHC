// -------- USER SETTINGS --------
outputDir = "D:/R251G_IHC_20260115/IHC/R251G/CA1/MBP_OUTPUT/";

// -------- START --------

// Get currently active image
origTitle = getTitle();

// Duplicate original image for processing
run("Duplicate...", "title=MBP_work");

// Make sure ROI is stored
roiManager("Add");

// Suggest an automatic threshold, but allow manual adjustment
setAutoThreshold("Otsu");
setOption("BlackBackground", false);
run("Threshold...");

// Pause macro for user interaction
waitForUser("Adjust threshold for MBP staining, then click OK to continue.");

// Convert to binary mask
run("Convert to Mask");

// Measure within ROI
roiIndex = roiManager("Count") - 1;
roiManager("Select", roiIndex);
run("Measure");

// ---- ADD IMAGE NAME TO RESULTS ----
row = nResults - 1;
setResult("Image", row, origTitle);
updateResults();

// Save Results table (unique name per image)
saveAs("Results", outputDir + replace(origTitle, ".tif", "_results.csv"));

// Save QC mask image
saveAs("Jpeg", outputDir + replace(origTitle, ".tif", "_mask.jpg"));

// Cleanup
close(); // close MBP_work

print("MBP quantification complete for: " + origTitle);