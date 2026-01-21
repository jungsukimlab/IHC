// Ensure composite mode so channels are accessible
Stack.setDisplayMode("composite");

// Enhance contrast on Channel 1
Stack.setChannel(1);
run("Enhance Contrast", "saturated=0.35");

// Enhance contrast on Channel 2
Stack.setChannel(2);
run("Enhance Contrast", "saturated=0.35");

// Optional set projection mode if needed
Property.set("CompositeProjection", "Sum");

// Initial fixed transformations
run("Rotate 90 Degrees Left");
run("Flip Horizontally");

// Ask user if they need further rotation
if (getBoolean("Do you need to rotate the image further?")) {
    
    // Loop until user confirms final rotation
    finalized = false;

    while (!finalized) {

        // Ask user for rotation angle
        Dialog.create("Fine Rotation");
        Dialog.addNumber("Enter rotation angle (degrees)", 0);
        Dialog.show();

        angle = Dialog.getNumber();

        // Apply rotation
        run("Rotate...", "angle=" + angle + " grid=1 interpolation=Bilinear enlarge");

        // Ask user to confirm
        Dialog.create("Confirm Rotation");
        Dialog.addMessage("Is this rotation final?");
        Dialog.addChoice("Confirm", newArray("No, adjust again", "Yes, finalize"), "No, adjust again");
        Dialog.show();

        choice = Dialog.getChoice();

        if (choice == "Yes, finalize") {
            finalized = true;
        }
    }
}
