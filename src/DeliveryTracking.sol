// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeliveryTracking {
    struct DeliveryGuy {
        uint256 totalDeliveries;
        uint256 successfulDeliveries;
        uint256 ratingSum;
        uint256 ratingCount;
    }

    struct Sender {
        uint256 totalPackagesSent;
    }

    mapping(address => DeliveryGuy) public deliveryGuys;
    mapping(address => Sender) public senders;

    event DeliveryCompleted(address deliveryGuy, uint8 rating, bool success);
    event PackageSent(address sender);

    // Modifier to ensure valid ratings (between 1 and 5)
    modifier validRating(uint8 rating) {
        require(rating >= 1 && rating <= 5, "Rating must be between 1 and 5");
        _;
    }

    // Called when a package is successfully delivered to update delivery guy stats
    function completeDelivery(address deliveryGuy, uint8 rating, bool success) external validRating(rating) {
        DeliveryGuy storage dg = deliveryGuys[deliveryGuy];

        // Update the delivery guy's stats
        dg.totalDeliveries += 1;
        dg.ratingSum += rating;
        dg.ratingCount += 1;

        if (success) {
            dg.successfulDeliveries += 1;
        }

        emit DeliveryCompleted(deliveryGuy, rating, success);
    }

    // Calculate average rating for a delivery guy
    function getAverageRating(address deliveryGuy) external view returns (uint256) {
        DeliveryGuy storage dg = deliveryGuys[deliveryGuy];
        if (dg.ratingCount == 0) {
            return 0; // No ratings yet
        }
        return dg.ratingSum / dg.ratingCount;
    }

    // Calculate the completion rate for a delivery guy
    function getCompletionRate(address deliveryGuy) external view returns (uint256) {
        DeliveryGuy storage dg = deliveryGuys[deliveryGuy];
        if (dg.totalDeliveries == 0) {
            return 0; // No deliveries yet
        }
        return (dg.successfulDeliveries * 100) / dg.totalDeliveries; // Completion rate as a percentage
    }

    // Called when a sender creates a package
    function packageSent(address sender) external {
        senders[sender].totalPackagesSent += 1;
        emit PackageSent(sender);
    }

    // Get the total number of packages sent by a sender
    function getTotalPackagesSent(address sender) external view returns (uint256) {
        return senders[sender].totalPackagesSent;
    }
}
