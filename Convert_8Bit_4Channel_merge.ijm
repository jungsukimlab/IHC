// Select folder containing the images
dir = getDirectory("Choose a folder with channel images");
list = getFileList(dir);

// Loop over files and detect ch00 images as the reference
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], "_ch00.tif")) {

        // Base name (everything before _ch00.tif)
        base = replace(list[i], "_ch00.tif", "");

        // Define filenames for each channel
        ch00 = dir + base + "_ch00.tif"; // Blue
        ch01 = dir + base + "_ch01.tif"; // Red
        ch02 = dir + base + "_ch02.tif"; // Green
        ch03 = dir + base + "_ch03.tif"; // Magenta

        // Open and convert all channels to 8-bit
        open(ch00); run("8-bit"); rename("Blue");
        open(ch01); run("8-bit"); rename("Red");
        open(ch02); run("8-bit"); rename("Green");
        open(ch03); run("8-bit"); rename("Magenta");

        // Merge channels
        run("Merge Channels...",
            "red=Red green=Green blue=Blue gray=Magenta create");

        // Convert to composite so colors can be assigned
        run("Make Composite");

        // Set LUTs explicitly
        Stack.setChannel(1); run("Red");
        Stack.setChannel(2); run("Green");
        Stack.setChannel(3); run("Blue");
        Stack.setChannel(4); run("Magenta");

        // Save merged image
        saveAs("Tiff", dir + base + "_chall.tif");

        // Close all images before next loop
        close("*");
    }
}