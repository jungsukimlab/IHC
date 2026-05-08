macro "Batch Measure Luxol Fast Blue" {

    // ---- User settings ----
    inputDir  = "D:/5XFAD_PS19_LFB_20260509/02_5X/WM/";
    outputDir = "D:/5XFAD_PS19_LFB_20260509/02_5X/OUTPUT/";
    outputCSV = outputDir + "LFB_results.csv";

    // ---- Setup ----
    File.makeDirectory(outputDir);
    run("Clear Results");
    setBatchMode(true);

    list = getFileList(inputDir);

    for (i = 0; i < list.length; i++) {
        file = list[i];
        path = inputDir + file;

        // Skip folders
        if (File.isDirectory(path))
            continue;

        // Process common image formats only
        if (!(endsWith(file, ".tif") || endsWith(file, ".tiff") ||
              endsWith(file, ".png") || endsWith(file, ".jpg") ||
              endsWith(file, ".jpeg") || endsWith(file, ".bmp"))) {
            continue;
        }

        open(path);
        origTitle = getTitle();
        bit = bitDepth();

        // Measure blue channel for RGB images
        if (bit == 24) {
            run("RGB Split");
            selectWindow(origTitle + " (blue)");
        }

        // Measure whole image
        run("Select All");
        run("Set Measurements...", "area mean min max integrated decimal=3");
        run("Measure");

        row = nResults - 1;
        mean = getResult("Mean", row);

        // Stain proxy: darker stain -> higher value
        if (bit == 16) {
            maxVal = 65535;
        } else if (bit == 32) {
            maxVal = 1.0;
        } else {
            maxVal = 255;
        }

        lfbProxy = maxVal - mean;

        setResult("File", row, file);
        setResult("LFB_Proxy", row, lfbProxy);
        updateResults();

        // Close images to keep memory clean
        close();
        if (bit == 24) {
            selectWindow(origTitle + " (red)"); close();
            selectWindow(origTitle + " (green)"); close();
            selectWindow(origTitle + " (blue)"); close();
        }
    }

    setBatchMode(false);

    // Save results as CSV
    saveAs("Results", outputCSV);
    print("Saved results to: " + outputCSV);
}