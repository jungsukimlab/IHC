// Ask the user to select the sample image
showMessage("Select the Sample Image");
open();
sampleImage = getTitle();

// Ask the user to select the standard image (template)
showMessage("Select the Standard Image");
open();
standardImage = getTitle();

// Select the sample image to apply the overlay
selectImage(sampleImage);

// Overlay the standard image on top of the sample with 18 opacity
// We use square brackets around the variable to handle spaces in filenames
run("Add Image...", "image=[" + standardImage + "] x=0 y=0 opacity=18");

// Convert the overlay to an ROI in the Manager
run("To ROI Manager");

// Select and close the standard image as it is now part of the overlay
selectImage(standardImage);
close();

// Select the sample image again to ensure it is active
selectImage(sampleImage);

// Create the specific rectangle selection defined in your request
makeRectangle(-948, -96, 6942, 9090);