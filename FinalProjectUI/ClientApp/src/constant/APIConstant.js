"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var APIBaseConstant = /** @class */ (function () {
    function APIBaseConstant() {
        this.baseUrl = "https://finalprojectapi01.azurewebsites.net/api/";
        this.homeindexUrl = "home/index";
        /*
        * API URL: baseUrl + getUserByEmail
        * Type: GET
        * Param: email(string)
        * Response: User
        */
        this.getUserByEmail = "user/GetUserByEmail";
    }
    return APIBaseConstant;
}());
exports.APIBaseConstant = APIBaseConstant;
//# sourceMappingURL=APIConstant.js.map