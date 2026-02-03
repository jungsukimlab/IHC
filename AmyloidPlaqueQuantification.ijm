// ===============================
// Batch DAB / Area Analysis Macro
// Fixed Threshold & Particle Size
// ===============================

// Select input folder
inputDir = getDirectory("Choose input folder with TIFF images");

// Select output folder
outputDir = getDirectory("Choose output folder for analyzed images");

// Get file list
list = getFileList(inputDir);

// Loop through all files
for (i = 0; i < list.length; i++) {

    if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {

        // Open image
        open(inputDir + list[i]);
        origTitle = getTitle();

        // ROI
        Roi.setPosition(1);
        roiManager("Reset");
        roiManager("Add");

        // Convert to RGB then 8-bit
        run("RGB Color");
        run("8-bit");

        // ===============================
        // FIXED THRESHOLD
        // ===============================
        setThreshold(0, 162);
        setOption("BlackBackground", false);
        run("Convert to Mask");

        // Apply ROI
        roiManager("Select", 0);

        // ===============================
        // ANALYZE PARTICLES
        // ===============================
        run(
            "Analyze Particles...",
            "size=5-3000 display exclude summarize overlay"
        );

        // ===============================
        // SAVE ANALYZED IMAGE
        // ===============================
        saveAs(
            "Tiff",
            outputDir + origTitle + " (RGB).tif"
        );

        // Close all images before next file
        while (nImages > 0) {
            selectImage(nImages);
            close();
        }
    }
}
