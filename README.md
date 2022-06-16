![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20macOS-333333.svg)
[![License](https://img.shields.io/github/license/NordicSemiconductor/IOS-nRF-Edge-Impulse)](https://github.com/NordicSemiconductor/IOS-nRF-Edge-Impulse/blob/master/LICENSE)

# nRF Edge Impulse

# Introduction

![nRF Edge Impulse](https://apps.apple.com/us/app/nrf-edge-impulse/id1557234087) app is developed in collaboration with ![Edge Impulse](https://www.edgeimpulse.com/) to train and deploy embedded machine learning models on the Nordic Thingy:53 using Edge Impulse Studio. Every Nordic Thingy:53™ comes pre-installed with firmware compatible with the nRF Edge Impulse mobile app. The app allows you to upload raw sensor data via your mobile device to the cloud-based Edge Impulse Studio and deploy fully trained ML models to the Nordic Thingy:53™ over Bluetooth® Low Energy (LE). 

## Features

The app allows you to choose between existing projects in Edge Impulse studio data or creating a new project and can collect sensor data from the following set of sensors on the Nordic Thingy:53:

* **Accelerometer**
* **Microphone**
* **Magnetometer**
* **Light**
* **Temperature, Pressure, Humidity and Air quality**
* **Light and Environment**
* **Inertial (Accelerometer and Magnetometer)**
* **Environment and Inertial**
* **Light, Environment and Inertial**

The collected sensor data can be labeled as training or testing data and may be inferenced directly in the app with machine learning model deployed to the Nordic Thingy:53.

## Requirements

* **Account**: A free ![Edge Impulse](https://studio.edgeimpulse.com/signup) Account, which may created from the app or at www.edgeimpulse.com, is required to connect nRF Edge Impulse with Edge Impulse Studio server.
* **OS**: Minimum required iOS version is 15.0 (released Fall of 2021), and for macOS it's 12.0 (Monterey).
* **Tools**: Built using Xcode 13.

# Target Hardware

![Thingy:53](https://www.nordicsemi.com/-/media/Images/Products/Prototyping-platforms/Thingy-53/OG-image-Nordic-Thingy53.jpg)

nRF Edge Impulse is a ![Launch Application](https://www.nordicsemi.com/News/2022/06/Nordic-Thingy53) for our ![Nordic Thingy:53™](https://www.nordicsemi.com/Products/Development-hardware/Nordic-Thingy-53) hardware, for which an introductory video, including video of this app, can be found ![here](https://www.youtube.com/watch?v=PQhlOITwQTo). As a short introduction, Thingy:53 is based on Nordic’s nRF5340 dual-core Arm® Cortex® M-33 advanced multiprotocol System-on-Chip (SoC) and incorporates the company’s nPM1100 Power Management IC (PMIC) and nRF21540 Front End Module (FEM), a power amplifier/low noise amplifier (PA/LNA) range extender. The prototyping platform is equipped with a rechargeable 1350 mAh Li-poly battery and multiple motion and environmental sensors. It supports Bluetooth® Low Energy (Bluetooth LE), Thread, Matter, Zigbee, IEEE 802.15.4, NFC, and Bluetooth mesh RF protocols, and comes with preinstalled firmware for embedded ML directly on the Thingy:53.

For an in-depth look at our available Developer Documentation for Thingy:53, have a look ![here](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/ug_thingy53.html).

# Development History

## Initial Release (June 2022)

![SwiftUI Logo](https://developer.apple.com/news/images/og/swiftui-og.png)

From the start of the project, nRF Edge Impulse was proposed as an opportunity for the team to learn new and emerging tecnologies in the Swift / iOS world, such as ![SwiftUI](https://developer.apple.com/xcode/swiftui/) and ![Combine](https://developer.apple.com/documentation/combine). This also allowed us to make our first multi-platform project, since being SwiftUI since the start, means nRF Edge Impulse ran on iPhone, iPad and Mac from the first commit onwards. This is reflected throughout the project's Git history, which we have kept intact, with all of its faults (and please, forgive some of our bad days in which we weren't as understanding with some of our comrades), because it might help answer some questions regarding 'Why was X not solved this other way?' It also reflects the path we went through to learn SwiftUI, Combine and also how to play well with ![CoreBluetooth](https://developer.apple.com/documentation/corebluetooth), our bread and butter, just before Swift ![Actors](https://developer.apple.com/documentation/swift/actor) landed half-way through development. It was too late then to go back and re-implement our working BLE logic to use Actors, since the underlying skeleton of the app was already in place, and we were under constant SwiftUI bug alerts, wherein some members of the team had unexpected broken UIs after random TestFlight betas. Why? They were running a different "dot release" of iOS. Which ![was fine](https://imgflip.com/memegenerator/This-Is-Fine).

It was also a very weird project in regards to macOS, because SwiftUI did a lot of the work to make our declarative UIs looked like they belong within the borders of an iPhone or iPad, but not when running on the Mac. This required declarations of separate Swift View(s) to make the app running on the Mac hurt our eyes less, but it was clear from the start SwiftUI was not tailored for the Mac. This looks to have been addressed with SwiftUI 4 and macOS Ventura, but it's still too early to tell. This is to say, yes we know, nRF Edge Impulse could do better on the Mac. 
