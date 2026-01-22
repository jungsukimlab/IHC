// ===============================
// DAB Quantification Macro
// ===============================

// Get original info
origTitle = getTitle();
outputDir = getDirectory("image"); // Saves to the same folder the image is in

// If you prefer a specific folder, uncomment the line below:
// outputDir = "C:/Users/YourName/Desktop/Results/"; 

// Add ROI (based on your current selection)
if (selectionType() == -1) {
    run("Select All"); // Ensure something is selected if no ROI exists
}
roiManager("Add");

// Convert to RGB
// After this, title becomes: "HP_134_4-5_1737_2-1.tif (RGB)"
run("RGB Color");
rgbTitle = getTitle();

// Colour Deconvolution (H DAB)
// This creates: 
// 1. "HP_134_4-5_1737_2-1.tif (RGB)-(Colour_1)" (Hematoxylin)
// 2. "HP_134_4-5_1737_2-1.tif (RGB)-(Colour_2)" (DAB)
// 3. "HP_134_4-5_1737_2-1.tif (RGB)-(Colour_3)" (Residual)
run("Colour Deconvolution", "vectors=[H DAB]");

// Define the exact titles produced by the plugin
dabTitle = rgbTitle + "-(Colour_2)";
resTitle = rgbTitle + "-(Colour_3)";
hTitle   = rgbTitle + "-(Colour_1)";

// Close unnecessary channels immediately to avoid confusion
if (isOpen(resTitle)) { selectWindow(resTitle); close(); }
if (isOpen(hTitle))   { selectWindow(hTitle);   close(); }

// ===============================
// SAVE DAB IMAGE (RAW)
// ===============================
selectWindow(dabTitle);

// This saves exactly: HP_134_4-5_1737_2-1.tif (RGB)-(Colour_2)_RAW_DAB.tif
saveAs("Tiff", outputDir + dabTitle + "_RAW_DAB.tif");

// After saveAs, the window title in ImageJ actually changes to the filename.
// We update our variable to match the new window name so the macro doesn't lose focus.
dabTitle = getTitle(); 

// ===============================
// THRESHOLD + ANALYSIS
// ===============================

// Set auto-threshold as starting point
setAutoThreshold("Otsu no-reset");

// Allow user adjustment
run("Threshold...");
waitForUser(
    "Adjust threshold for DAB staining.\n" +
    "Click 'Apply' in Threshold window.\n" +
    "Then click OK here to continue."
);

// Convert to mask
setOption("BlackBackground", false);
run("Convert to Mask");

// Apply ROI from the manager
roiManager("Select", 0);

// Analyze particles
run("Analyze Particles...", "size=2-10000 show=Outlines display exclude summarize overlay");

// Save final processed mask
saveAs("Tiff", outputDir + dabTitle + "_MASK.tif");

// ===============================
// CLEAN UP
// ===============================
// Close everything and clear ROI Manager
roiManager("Delete");
while (nImages > 0) {
    selectImage(nImages);
    close();
}