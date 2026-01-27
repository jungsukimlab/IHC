// -------- USER SETTINGS --------
outputDir = "/Volumes/KimLab_MRI5/SAA_KI_ASPA_MBP_NeuN_20260116/WT_SAA_KI_VEHICLE_ROI/RSA/ASPA/";

backgroundRadius = 40;     // sliding background (20–50 typical)
minSize = 10;              // µm²
maxSize = 300;             // µm²
minCirc = 0.5;
maxCirc = 1.0;

// -------- START --------

// Get active image
origTitle = getTitle();

// Duplicate image
run("Duplicate...", "title=ASPA_work");

// Store ROI
roiManager("Add");
roiIndex = roiManager("Count") - 1;

// Convert to 8-bit
run("8-bit");

// Sliding paraboloid background subtraction
run(
    "Subtract Background...",
    "rolling=" + backgroundRadius + " sliding"
);

// Mild smoothing to reduce noise
run("Gaussian Blur...", "sigma=0.5");

// Suggest threshold but allow manual adjustment
setAutoThreshold("Otsu dark");
setOption("BlackBackground", false);
run("Threshold...");

// Pause for user QC
waitForUser(
    "Adjust threshold to capture ASPA+ oligodendrocyte somata.\n" +
    "Avoid thin processes.\n" +
    "Click OK to continue."
);

// Convert to mask
run("Convert to Mask");

// Fill holes (important for cell bodies)
run("Fill Holes");

// Separate touching cells
run("Watershed");

// Apply ROI
roiManager("Select", roiIndex);

// Analyze particles (cell counting)
run(
    "Analyze Particles...",
    "size=" + minSize + "-" + maxSize +
    " circularity=" + minCirc + "-" + maxCirc +
    " show=Outlines display clear summarize"
);

// Save results
saveAs("Results", outputDir + replace(origTitle, ".tif", "_ASPA_cells.csv"));

// Save QC outline image
saveAs("Jpeg", outputDir + replace(origTitle, ".tif", "_ASPA_QC.jpg"));

// Cleanup
close();
print("ASPA oligodendrocyte quantification complete for: " + origTitle);
