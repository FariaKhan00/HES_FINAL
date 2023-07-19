import 'package:firebase_auth/firebase_auth.dart';
import 'package:userapp/models/user_models.dart';

import '../models/direction_details.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; //drivers list
DirectionDetailsInfo? tripDirectionDetailsInfo;
String? chosenDriverId = "";
String cloudMessagingServerToken =
    "key=AAAAoUZsqCA:APA91bEpZjPr2WUV6zF_9P32xGuVNiJp2_K8rWZ7APCaA4cVAyVNFR-ONSYeJsChlYZ2yGa3a0chPB-bSww7h4vq2se_nE8YEgNJb2sGIEdoI3e_mbUzghwP_RvXLuEnfIEs0TwxskPr";

String userDropOffAddress = "";

String driverCarDetails = "";
String driverName = "";
String driverPhoneNo = "";
double countRatingStars = 0.0;
String titleStarRating = "";
