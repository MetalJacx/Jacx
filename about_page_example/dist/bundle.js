define(['exports', '@angular/common', '@angular/core', '@angular/router', '@ngrx/store', '@vcd-ui/common'], function (exports, _angular_common, _angular_core, _angular_router, _ngrx_store, _vcdUi_common) { 'use strict';

function __decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}

function __metadata(k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
}

function __param(paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
}

/** vcloud-director-ui-extension-sample-about-page
 *  SPDX-License-Identifier: BSD-2-Clause
 *  Copyright 2018 VMware, Inc. All rights reserved. VMware Confidential
 */
var AboutComponent = (function () {
    function AboutComponent() {
    }
    return AboutComponent;
}());
AboutComponent = __decorate([
    _angular_core.Component({
        selector: 'about-component',
        template: "<!--* vcloud-director-ui-extension-sample-about-page\n    *  SPDX-License-Identifier: BSD-2-Clause\n    *  Copyright 2018 VMware, Inc. All rights reserved. VMware Confidential\n    *-->\n\n<div class=\"content-area\">\n  <h1>About PhoenixNap Hosting</h1>\n\n  <p>\n  Founded in 2009, phoenixNAP\u2019s mission has always been to provide outstanding value and service, using state-of-the-art technology, while continually improving our technical and human assets. It is through these methods that we are able to maintain an incredibly customer responsive experience that puts their needs first. We remove the stress from IT management, so our customers can focus on their core business.\n  <p>\n  When you work with phoenixNAP, you don\u2019t just get a state-of-the-art, catastrophe-free Data Center, you gain access to our greatest asset\u2014our people. PhoenixNAP employees are highly skilled professionals who maintain leading-edge knowledge of our hardware, software, and security measures. The phoenixNAP team is always here waiting to help. From our sales experts to our support team, we have one goal in mind: your success.\n\n  <h2>Services Available</h2>\n  <li>Colocation Services</li>\n  <li>Cloud Services</li>\n  <li>Dedicated Servers</li>\n  <li>Bare Metal Servers</li>\n  <li>Amazon Web Services,/li>\n\n  <h2>Contact Information</h2>\n  <li>Phone: 1-855-330-1509</li>\n  <li>Email: support@phoenixnap.comm</li>\n</div>\n",
        host: { 'class': 'content-container' }
    })
], AboutComponent);

var ROUTES = [
    {
        path: '',
        component: AboutComponent
    }
];

/** vcloud-director-ui-extension-sample-about-page
 *  SPDX-License-Identifier: BSD-2-Clause
 *  Copyright 2018 VMware, Inc. All rights reserved. VMware Confidential
 */
exports.AboutModule = (function () {
    function AboutModule(appStore, extensionRoute) {
        this.appStore = appStore;
        var registration = {
            path: extensionRoute,
            nameCode: "nav.about",
            descriptionCode: "nav.about.description"
        };
        appStore.dispatch(new _vcdUi_common.ExtensionNavRegistrationAction(registration));
    }
    return AboutModule;
}());
exports.AboutModule = __decorate([
    _angular_core.NgModule({
        imports: [
            _angular_common.CommonModule,
            _angular_router.RouterModule.forChild(ROUTES)
        ],
        declarations: [
            AboutComponent
        ],
        bootstrap: [
            AboutComponent
        ]
    }),
    __param(1, _angular_core.Inject(_vcdUi_common.EXTENSION_ROUTE)),
    __metadata("design:paramtypes", [typeof (_a = typeof _ngrx_store.Store !== "undefined" && _ngrx_store.Store) === "function" && _a || Object, String])
], exports.AboutModule);
var _a;

/** vcloud-director-ui-extension-sample-about-page
 *  SPDX-License-Identifier: BSD-2-Clause
 *  Copyright 2018 VMware, Inc. All rights reserved. VMware Confidential
 */

Object.defineProperty(exports, '__esModule', { value: true });

});
