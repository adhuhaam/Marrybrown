import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:efood_multivendor/data/repository/splash_repo.dart';
import 'package:efood_multivendor/util/html_type.dart';
import 'package:get/get.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;
  SplashController({required this.splashRepo});

  ConfigModel? _configModel;
  bool _firstTimeConnectionCheck = true;
  bool _hasConnection = true;
  int _nearestRestaurantIndex = -1;
  bool _savedCookiesData = false;
  String? _htmlText;

  ConfigModel? get configModel => _configModel;
  DateTime get currentTime => DateTime.now();
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  bool get hasConnection => _hasConnection;
  int get nearestRestaurantIndex => _nearestRestaurantIndex;
  bool get savedCookiesData => _savedCookiesData;
  String? get htmlText => _htmlText;

  Future<bool> getConfigData() async {
    _hasConnection = true;
    Response response = await splashRepo.getConfigData();
    bool isSuccess = false;
    if(response.statusCode == 200) {
      _configModel = ConfigModel.fromJson(response.body);
      isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      if(response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  bool? showIntro() {
    return splashRepo.showIntro();
  }

  void disableIntro() {
    splashRepo.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  void setNearestRestaurantIndex(int index, {bool notify = true}) {
    _nearestRestaurantIndex = index;
    if(notify) {
      update();
    }
  }

  void saveCookiesData(bool data) {
    splashRepo.saveCookiesData(data);
    _savedCookiesData = true;
    update();
  }

  getCookiesData(){
    _savedCookiesData = splashRepo.getSavedCookiesData();
    update();
  }

  void cookiesStatusChange(String? data) {
    splashRepo.cookiesStatusChange(data);
  }

  bool getAcceptCookiesStatus(String data) => splashRepo.getAcceptCookiesStatus(data);

  Future<void> getHtmlText(HtmlType htmlType) async {
    _htmlText = null;
    Response response = await splashRepo.getHtmlText(htmlType);
    if (response.statusCode == 200) {
      if(response.body != null && response.body.isNotEmpty && response.body is String){
        _htmlText = response.body;
      }else{
        _htmlText = '';
      }

      if(_htmlText != null && _htmlText!.isNotEmpty) {
        _htmlText = _htmlText!.replaceAll('href=', 'target="_blank" href=');
      }else {
        _htmlText = '';
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

}
