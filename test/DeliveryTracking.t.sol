// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol"; // Importing Foundry's Test library
import "../src/DeliveryTracking.sol"; // Adjust the path based on your project structure

contract DeliveryTrackingTest is Test {
    DeliveryTracking deliveryTracking;
    address deliveryGuy1 = address(0x123);
    address deliveryGuy2 = address(0x456);
    address sender1 = address(0x789);

    // Run before each test
    function setUp() public {
        // Deploy the contract
        deliveryTracking = new DeliveryTracking();
    }

    // Test the packageSent function
    function testPackageSent() public {
        // Call the packageSent function for sender1
        deliveryTracking.packageSent(sender1);

        // Check the total number of packages sent by sender1
        uint256 totalPackagesSent = deliveryTracking.getTotalPackagesSent(sender1);
        assertEq(totalPackagesSent, 1);
    }

    // Test the completeDelivery function with a valid rating and successful delivery
    function testCompleteDeliverySuccessful() public {
        // Call the completeDelivery function for deliveryGuy1
        deliveryTracking.completeDelivery(deliveryGuy1, 4, true);

        // Check the total deliveries and successful deliveries
        (uint256 totalDeliveries, uint256 successfulDeliveries, uint256 ratingSum, uint256 ratingCount) =
            deliveryTracking.deliveryGuys(deliveryGuy1);

        assertEq(totalDeliveries, 1);
        assertEq(successfulDeliveries, 1);
        assertEq(ratingSum, 4);
        assertEq(ratingCount, 1);
    }

    // Test the completeDelivery function with a valid rating and unsuccessful delivery
    function testCompleteDeliveryUnsuccessful() public {
        // Call the completeDelivery function for deliveryGuy2
        deliveryTracking.completeDelivery(deliveryGuy2, 3, false);

        // Check the total deliveries and successful deliveries
        (uint256 totalDeliveries, uint256 successfulDeliveries, uint256 ratingSum, uint256 ratingCount) =
            deliveryTracking.deliveryGuys(deliveryGuy2);

        assertEq(totalDeliveries, 1);
        assertEq(successfulDeliveries, 0); // Unsuccessful delivery
        assertEq(ratingSum, 3);
        assertEq(ratingCount, 1);
    }

    // Test that ratings must be between 1 and 5
    function testInvalidRating() public {
        // Expect the transaction to revert due to an invalid rating (0)
        vm.expectRevert("Rating must be between 1 and 5");
        deliveryTracking.completeDelivery(deliveryGuy1, 0, true);
    }

    // Test the getAverageRating function
    function testGetAverageRating() public {
        // Complete two deliveries for deliveryGuy1 with different ratings
        deliveryTracking.completeDelivery(deliveryGuy1, 5, true);
        deliveryTracking.completeDelivery(deliveryGuy1, 3, true);

        // Check the average rating
        uint256 averageRating = deliveryTracking.getAverageRating(deliveryGuy1);
        assertEq(averageRating, 4); // (5 + 3) / 2 = 4
    }

    // Test the getCompletionRate function
    function testGetCompletionRate() public {
        // Complete two deliveries, one successful and one unsuccessful
        deliveryTracking.completeDelivery(deliveryGuy1, 5, true);
        deliveryTracking.completeDelivery(deliveryGuy1, 3, false);

        // Check the completion rate
        uint256 completionRate = deliveryTracking.getCompletionRate(deliveryGuy1);
        assertEq(completionRate, 50); // 50% success rate
    }

    // Test multiple package sent for a sender
    function testMultiplePackageSent() public {
        // Call packageSent multiple times
        deliveryTracking.packageSent(sender1);
        deliveryTracking.packageSent(sender1);
        deliveryTracking.packageSent(sender1);

        // Check the total number of packages sent by sender1
        uint256 totalPackagesSent = deliveryTracking.getTotalPackagesSent(sender1);
        assertEq(totalPackagesSent, 3); // 3 packages sent
    }
}
