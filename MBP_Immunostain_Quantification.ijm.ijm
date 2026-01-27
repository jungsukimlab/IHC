// -------- USER SETTINGS --------
outputDir = "/Volumes/KimLab_MRI5/SAA_KI_ASPA_MBP_NeuN_20260116/WT_SAA_KI_VEHICLE_ROI/RSA/MBP/";

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

// Save Results table (unique name per image)
saveAs("Results", outputDir + replace(origTitle, ".tif", "_results.csv"));

// Save QC mask image
saveAs("Jpeg", outputDir + replace(origTitle, ".tif", "_mask.jpg"));

// Cleanup
close(); // close MBP_work

print("MBP quantification complete for: " + origTitle);