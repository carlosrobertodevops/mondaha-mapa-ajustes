// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Automatic FlutterFlow imports
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions

import '../../flutter_flow/flutter_flow_google_map.dart';
import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:image/image.dart' as img;

class CustomGoogleMapsMarkers extends StatefulWidget {
  const CustomGoogleMapsMarkers({
    super.key,
    this.width,
    this.height,
    this.artDocs,
    this.choosenMarker,
    this.onCameraIdle,
    this.enableZoomGesture,
    this.enableZoomControl,
    this.zoomLevel,
    this.minimumZoom,
    this.maximumZoom,
    this.showMapsCircles,
    this.mapsCirclesDiameter,
    this.mapsCirclesFillColor,
    this.mapsCircleBorderColor,
    this.mapsCircleBorderWidth,
    this.onDataLoaded,
    this.selectedLocation,
    this.restrictBounds = false,
  });

  final double? width;
  final double? height;
  final List<CompleteListRecord>? artDocs;
  final Future Function(LatLng? latLng)? choosenMarker;
  final Future Function(LatLng? latLng)? onCameraIdle;
  final bool? enableZoomGesture;
  final bool? enableZoomControl;
  final double? zoomLevel;
  final double? minimumZoom;
  final double? maximumZoom;
  final bool? showMapsCircles;
  final double? mapsCirclesDiameter;
  final Color? mapsCirclesFillColor;
  final Color? mapsCircleBorderColor;
  final int? mapsCircleBorderWidth;
  final Future Function()? onDataLoaded;
  final FFPlace? selectedLocation;
  final bool restrictBounds;

  @override
  State<CustomGoogleMapsMarkers> createState() =>
      _CustomGoogleMapsMarkersState();
}

class _CustomGoogleMapsMarkersState extends State<CustomGoogleMapsMarkers> {
  Completer<gmaps.GoogleMapController> _controller =
      Completer<gmaps.GoogleMapController>();
  Set<gmaps.Marker> markers = {};
  Set<gmaps.Circle> circles = {};

  gmaps.LatLng? userLocation;
  bool markersLoadingDone = false;
  bool userLocationLoadingDone = false;
  bool circlesLoadingDone = false;

  final LatLngBounds australiaBounds = LatLngBounds(
    southwest: gmaps.LatLng(-44.0, 112.0),
    northeast: gmaps.LatLng(-10.0, 154.0),
  );

  late gmaps.LatLng currentMapCenter;
  void onCameraIdle() => widget.onCameraIdle?.call(currentMapCenter.toLatLng());

  @override
  void initState() {
    super.initState();
    _controller = Completer<gmaps.GoogleMapController>();
    _createMarkers();
    _createCircles();

    if (!selectedLocationPresent) {
      getCurrentUserLocation(
        defaultLocation: LatLng(0.0, 0.0),
        cached: true,
      ).then((location) {
        setState(() {
          userLocationLoadingDone = true;
          userLocation = gmaps.LatLng(location.latitude, location.longitude);
          currentMapCenter = userLocation ?? gmaps.LatLng(0.0, 0.0);
        });
      });
    } else {
      userLocationLoadingDone = true;
    }
  }

  bool get selectedLocationPresent {
    return widget.selectedLocation != null &&
        widget.selectedLocation!.latLng.longitude != 0 &&
        widget.selectedLocation!.latLng.latitude != 0;
  }

  /// Marker creation start
  void _createMarkers() async {
    if (widget.artDocs != null) {
      for (var artDoc in widget.artDocs!) {
        if (artDoc.geo != null) {
          try {
            final geoCoordinates = artDoc.geo!;
            final latitude = geoCoordinates.latitude;
            final longitude = geoCoordinates.longitude;

            final markerIcon = await BitmapDescriptor.asset(
              const ImageConfiguration(size: Size(50, 50)),
              _assetPathForMarkerUrl(artDoc.marker),
            );

            markers.add(
              gmaps.Marker(
                markerId: gmaps.MarkerId('$latitude,$longitude'),
                position: gmaps.LatLng(latitude, longitude),
                icon: markerIcon,
                anchor: const Offset(0.5, 0.5),
                onTap: () {
                  widget.choosenMarker!(LatLng(latitude, longitude));
                },
              ),
            );
          } catch (e) {
            print('Error loading marker image: $e');
          }
        }
      }
    }
    // Call the onDataLoaded callback when data is loaded
    if (widget.onDataLoaded != null) {
      widget.onDataLoaded!();
    }

    setState(() {
      markersLoadingDone = true;
    });
  }

  String _assetPathForMarkerUrl(String markerUrl) {
    const baseAssetPath = 'assets/images/';

    final decodedUrl = Uri.decodeFull(markerUrl);

    final regex = RegExp(r'([^/]+\.png)(?:\?|$)');
    final match = regex.firstMatch(decodedUrl);

    if (match != null) {
      final assetName = match.group(1)!.replaceAll(' ', '_');
      return '$baseAssetPath$assetName';
    } else {
      return '${baseAssetPath}Street_Art.png';
    }
  }

  void _createCircles() async {
    if (widget.artDocs != null && widget.showMapsCircles == true) {
      for (var artDoc in widget.artDocs!) {
        if (artDoc.geo != null) {
          circles.add(
            gmaps.Circle(
              circleId: gmaps.CircleId(
                'C${artDoc.geo!.latitude},${artDoc.geo!.longitude}',
              ),
              center: gmaps.LatLng(artDoc.geo!.latitude, artDoc.geo!.longitude),
              fillColor:
                  widget.mapsCirclesFillColor ??
                  const Color.fromARGB(255, 200, 230, 255),
              strokeColor:
                  widget.mapsCircleBorderColor ??
                  const Color.fromARGB(255, 50, 163, 255),
              strokeWidth: widget.mapsCircleBorderWidth ?? 1,
              radius: widget.mapsCirclesDiameter ?? 150, // Default diameter
              onTap: () {
                widget.choosenMarker!(
                  LatLng(artDoc.geo!.latitude, artDoc.geo!.longitude),
                );
              },
            ),
          );
        }
      }
    }
    setState(() {
      circlesLoadingDone = true;
    }); // Update the state to reflect new circles
  }

  /// Getting icons end
  double? zoomLevelVar;
  late gmaps.MinMaxZoomPreference minMaxZoom;

  gmaps.LatLng? lastLocationToNavigate;
  gmaps.LatLng? selectedLocationWasShown;

  @override
  Widget build(BuildContext context) {
    if (!markersLoadingDone || !circlesLoadingDone || !userLocationLoadingDone)
      return SizedBox();

    gmaps.LatLng? selectedLocation =
        widget.selectedLocation != null
            ? gmaps.LatLng(
              widget.selectedLocation!.latLng.latitude,
              widget.selectedLocation!.latLng.longitude,
            )
            : null;

    // Function to calculate the average of a list of numbers
    double average(List<double> numbers) {
      return numbers.reduce((value, element) => value + element) /
          numbers.length;
    }

    if (widget.zoomLevel == null) {
      zoomLevelVar = 2;
    } else {
      zoomLevelVar = widget.zoomLevel;
    }

    if (widget.minimumZoom != null && widget.maximumZoom != null) {
      minMaxZoom = gmaps.MinMaxZoomPreference(
        widget.minimumZoom,
        widget.maximumZoom,
      );
    } else {
      minMaxZoom = gmaps.MinMaxZoomPreference(null, null);
    }

    // Extracting all latitudes and longitudes from ArtGeopoints
    List<double> latitudes = [];
    List<double> longitudes = [];

    if (widget.artDocs != null) {
      for (var artDoc in widget.artDocs!) {
        if (artDoc.geo != null) {
          latitudes.add(artDoc.geo!.latitude);
          longitudes.add(artDoc.geo!.longitude);
        }
      }
    }

    // Calculating the average latitude and longitude
    double averageLatitude = latitudes.isNotEmpty ? average(latitudes) : 0.0;
    double averageLongitude = longitudes.isNotEmpty ? average(longitudes) : 0.0;

    // Set the initial position to the average coordinates
    gmaps.LatLng initialPosition = gmaps.LatLng(
      averageLatitude,
      averageLongitude,
    );

    Future<void> _goToLocation(gmaps.LatLng coordinates) async {
      final GoogleMapController controller = await _controller.future;

      final _radius = /*model.myLocation ? 1 : */ areaRadius;

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          boundsFromLatLngList([
            offset(coordinates, _radius * 1609.34 * 2, 90),
            offset(coordinates, _radius * 1609.34 * 2, 90),
            offset(coordinates, _radius * 1609.34 * 2, -90),
          ]),
          1,
        ),
      );
    }

    gmaps.LatLng? locationToNavigate;

    if (userLocation != null) {
      locationToNavigate = gmaps.LatLng(
        userLocation!.latitude,
        userLocation!.longitude,
      );
      userLocation = null;
    } else if (selectedLocation != null && selectedLocationPresent) {
      locationToNavigate = gmaps.LatLng(
        selectedLocation.latitude,
        selectedLocation.longitude,
      );
      //locationToNavigate = selectedLocation ?? initialPosition;
    }

    if (locationToNavigate != null &&
        lastLocationToNavigate?.latitude != locationToNavigate.latitude &&
        lastLocationToNavigate?.longitude != locationToNavigate.longitude) {
      _goToLocation(locationToNavigate);
      lastLocationToNavigate = gmaps.LatLng(
        locationToNavigate.latitude,
        locationToNavigate.longitude,
      );
    }

    return gmaps.GoogleMap(
      onCameraIdle: onCameraIdle,
      onCameraMove: (position) => currentMapCenter = position.target,
      cameraTargetBounds:
          widget.restrictBounds
              ? CameraTargetBounds(australiaBounds)
              : CameraTargetBounds.unbounded,
      zoomControlsEnabled: widget.enableZoomControl ?? true,
      zoomGesturesEnabled: widget.enableZoomGesture ?? true,
      initialCameraPosition: gmaps.CameraPosition(
        target:
            selectedLocationPresent
                ? selectedLocation ?? initialPosition
                : userLocation ?? initialPosition,
        zoom: zoomLevelVar ?? 4,
      ),
      markers: markers,
      circles: circles,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      minMaxZoomPreference: minMaxZoom,
      onMapCreated: (gmaps.GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  double _areaRadius = 5; //25
  double get areaRadius => _areaRadius;

  set areaRadius(double newValue) {
    setState(() {
      _areaRadius = newValue;
    });
  }

  LatLngBounds boundsFromLatLngList(List<gmaps.LatLng> list) {
    double? x0, x1, y0, y1;
    for (gmaps.LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: gmaps.LatLng(x1!, y1!),
      southwest: gmaps.LatLng(x0!, y0!),
    );
  }

  /// Equator radius in meter (WGS84 ellipsoid)
  double _equatorRadius = 6378137.0;

  /// Converts degree to radian
  double degToRadian(final double deg) => deg * (math.pi / 180.0);

  /// Radian to degree
  double radianToDeg(final double rad) => rad * (180.0 / math.pi);

  gmaps.LatLng offset(
    final gmaps.LatLng from,
    final double distanceInMeter,
    final double bearing,
  ) {
    //Validate.inclusiveBetween(-180.0,180.0,bearing,"Angle must be between -180 and 180 degrees but was $bearing");

    final double h = degToRadian(bearing.toDouble());

    final double a = distanceInMeter / _equatorRadius;

    final double lat2 = math.asin(
      math.sin(degToRadian(from.latitude)) * math.cos(a) +
          math.cos(degToRadian(from.latitude)) * math.sin(a) * math.cos(h),
    );

    final double lng2 =
        degToRadian(from.longitude) +
        math.atan2(
          math.sin(h) * math.sin(a) * math.cos(degToRadian(from.latitude)),
          math.cos(a) - math.sin(degToRadian(from.latitude)) * math.sin(lat2),
        );

    return gmaps.LatLng(radianToDeg(lat2), radianToDeg(lng2));
  }
}
