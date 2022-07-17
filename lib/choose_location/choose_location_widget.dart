import '../auth/auth_util.dart';
import '../backend/backend.dart';
import '../backend/push_notifications/push_notifications_util.dart';
import '../flutter_flow/flutter_flow_google_map.dart';
import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_place_picker.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import '../flutter_flow/lat_lng.dart';
import '../flutter_flow/place.dart';
import 'dart:io';
import '../custom_code/actions/index.dart' as actions;
import '../flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseLocationWidget extends StatefulWidget {
  const ChooseLocationWidget({
    Key key,
    this.skillType,
    this.defaultLocation,
  }) : super(key: key);

  final String skillType;
  final LatLng defaultLocation;

  @override
  _ChooseLocationWidgetState createState() => _ChooseLocationWidgetState();
}

class _ChooseLocationWidgetState extends State<ChooseLocationWidget> {
  DocumentReference serviceProvider;
  RequestsRecord requestDocument;
  LatLng googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  var placePickerValue = FFPlace();
  RequestsRecord requestDocument;
  ServiceProvidersRecord serviceProviderDocument;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => setState(() => currentUserLocationValue = loc));
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserLocationValue == null) {
      return Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            color: FlutterFlowTheme.of(context).tertiaryColor,
          ),
        ),
      );
    }
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFEFEFEF),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1,
                      decoration: BoxDecoration(),
                      child: FlutterFlowGoogleMap(
                        controller: googleMapsController,
                        onCameraIdle: (latLng) => googleMapsCenter = latLng,
                        initialLocation: googleMapsCenter ??=
                            currentUserLocationValue,
                        markerColor: GoogleMarkerColor.rose,
                        mapType: MapType.normal,
                        style: GoogleMapStyle.standard,
                        initialZoom: 8,
                        allowInteraction: true,
                        allowZoom: true,
                        showZoomControls: false,
                        showLocation: true,
                        showCompass: false,
                        showMapToolbar: false,
                        showTraffic: false,
                        centerMapOnMarkerTap: true,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 30,
                        borderWidth: 1,
                        buttonSize: 60,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 30,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                      FlutterFlowPlacePicker(
                        iOSGoogleMapsApiKey:
                            'AIzaSyATcjTwA2AeCvz3O4nEsbbcQs_wN-AnsaA',
                        androidGoogleMapsApiKey:
                            'AIzaSyDRW63h78kpAtzzfJB0AWsX-KoDMWVY48I',
                        webGoogleMapsApiKey:
                            'AIzaSyDvleVM3I0xHDKgOFrqY72K9Bsie5dH4go',
                        onSelect: (place) async {
                          setState(() => placePickerValue = place);
                        },
                        defaultText: 'Click to Select Location',
                        icon: Icon(
                          Icons.place,
                          color: FlutterFlowTheme.of(context).tertiaryColor,
                          size: 16,
                        ),
                        buttonOptions: FFButtonOptions(
                          width: 250,
                          height: 40,
                          color: FlutterFlowTheme.of(context).secondaryColor,
                          textStyle: FlutterFlowTheme.of(context)
                              .subtitle2
                              .override(
                                fontFamily: 'Lexend Deca',
                                color:
                                    FlutterFlowTheme.of(context).tertiaryColor,
                              ),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: AlignmentDirectional(0, 0.77),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if ((placePickerValue.latLng != null))
                                FFButtonWidget(
                                  onPressed: () async {
                                    final requestsCreateData =
                                        createRequestsRecordData(
                                      userId: currentUserReference,
                                      status: 'Pending',
                                    );
                                    var requestsRecordReference =
                                        RequestsRecord.collection.doc();
                                    await requestsRecordReference
                                        .set(requestsCreateData);
                                    requestDocument =
                                        RequestsRecord.getDocumentFromData(
                                            requestsCreateData,
                                            requestsRecordReference);

                                    final destinationCreateData =
                                        createDestinationRecordData(
                                      location: placePickerValue.latLng,
                                      address: placePickerValue.name,
                                    );
                                    await DestinationRecord.createDoc(
                                            requestDocument.reference)
                                        .set(destinationCreateData);
                                    serviceProvider = await actions.getSP(
                                      currentUserDocument?.location,
                                      widget.skillType,
                                    );

                                    final requestsUpdateData =
                                        createRequestsRecordData(
                                      spId: serviceProvider,
                                    );
                                    await requestDocument.reference
                                        .update(requestsUpdateData);
                                    triggerPushNotification(
                                      notificationTitle: 'Job request',
                                      notificationText:
                                          functions.notificationText(
                                              currentUserDisplayName),
                                      notificationSound: 'default',
                                      userRefs: [serviceProviders],
                                      initialPageName: 'home',
                                      parameterData: {},
                                    );

                                    setState(() {});
                                  },
                                  text: 'Confirm',
                                  options: FFButtonOptions(
                                    width: 150,
                                    height: 50,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryColor,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Lexend Deca',
                                          color: FlutterFlowTheme.of(context)
                                              .tertiaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                    elevation: 2,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .tertiaryColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
