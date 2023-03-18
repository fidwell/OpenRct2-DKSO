import javax.imageio.ImageIO;
import java.awt.image.*;
import java.io.File;
import java.io.IOException;
import java.util.Scanner;

public class RecolourRctImage {
	public static void main(String[] args) {
		File file = new File(args[0]);
		
		if (!file.exists()) {
			System.out.println("Could not find file!");
			return;
		}
		
		BufferedImage image;
		try {
			image = ImageIO.read(file);
		} catch (IOException e) {
			System.out.println("Could not open file for some reason!");
			return;
		}

		// Make sure it's indexed-colored.
		if (image.getType() != BufferedImage.TYPE_BYTE_INDEXED) {
			System.out.println("Image does not seem to be indexed-colored!");
			return;
		}

		// Get a handle on it (and make a copy of its data the way that seemed to work).
		DataBuffer imageDataBuffer = image.getRaster().getDataBuffer();
		int[] imageDataBufferElementsCopy = new int[imageDataBuffer.getSize()];
		for (int i = 0; i < imageDataBuffer.getSize(); i++) {
			imageDataBufferElementsCopy[i] = imageDataBuffer.getElem(i);
		}
		
		int[] fromIndexes = { 10, 22, 34, 46, 58, 70, 82, 94, 106, 118, 130, 142, 154, 166, 178, 190, 214 };
		int targetIndex = 243;
		int rangeSize = 12;
		
		for (int c = 0; c < fromIndexes.length; c++) {
			int mappingSourceStart = fromIndexes[c];
			int mappingSourceEnd = mappingSourceStart + rangeSize - 1;
			int mappingDestinationStart = targetIndex;
			
			for (int i = 0; i < imageDataBuffer.getSize(); i++) {
				int colorIndex = imageDataBufferElementsCopy[i];
				if ((colorIndex >= mappingSourceStart && colorIndex <= mappingSourceEnd) ||
						colorIndex <= mappingSourceEnd - 0x100) { // handles wrap-around ranges (part 2)
					colorIndex = (mappingDestinationStart - mappingSourceStart + colorIndex) & 0xFF;
					imageDataBuffer.setElem(i, colorIndex);
				}
			}
		}
		
		try {
			ImageIO.write(image, "png", file);
		} catch (IOException e2) {
			System.out.println("Could not write file for some reason!");
		}
	}
}