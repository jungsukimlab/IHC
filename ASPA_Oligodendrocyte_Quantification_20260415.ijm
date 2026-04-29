// -------- USER SETTINGS --------
outputDir = "D:/R251G_IHC_20260115/IHC/APOE4/CA1/ASPA_OUTPUT/";   // change as needed

// -------- SETTINGS --------
minSize = 10;
maxSize = 1000;
minCirc = 0.3;
maxCirc = 1.0;

// -------- START --------
// Get active image
origTitle = getTitle();
origTitle = getTitle();

// Rename original to avoid conflict
rename("temp_original");

// Duplicate with original name
run("Duplicate...", "title=" + origTitle);

// Close original to avoid confusion
selectWindow("temp_original");
close();
run("8-bit");

// Background subtraction (gentler)
run("Subtract Background...", "rolling=30");

// Light smoothing
run("Gaussian Blur...", "sigma=0.5");

// Better threshold choice for IF
setAutoThreshold("Triangle dark");  // <-- more stable than Otsu for sparse cells
setOption("BlackBackground", false);

run("Threshold...");
waitForUser("Adjust threshold so ONLY soma are red");

// Convert to mask
run("Convert to Mask");

// Fill soma
run("Fill Holes");

// ⚠️ Temporarily REMOVE watershed (can destroy small cells)
// run("Watershed");

// NO erosion for now

// Analyze
run(
    "Analyze Particles...",
    "size=" + minSize + "-" + maxSize +
    " circularity=" + minCirc + "-" + maxCirc +
    " exclude show=Outlines display clear summarize"
);

// Save results
saveAs("Results", outputDir + replace(origTitle, ".tif", "_ASPA_cells.csv"));

// Save QC outline image
saveAs("Jpeg", outputDir + replace(origTitle, ".tif", "_ASPA_QC.jpg"));

// Cleanup
close();
print("ASPA oligodendrocyte quantification complete for: " + origTitle);