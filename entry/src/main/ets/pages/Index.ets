/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import SideBar from './view/SideBar'
import SideBarContent from './view/SideBarContent'
import SideBarContentBac from './view/SideBarContentBac'
import { CityModel } from '../model/CityModel'
import { WeatherUiModel } from '../model/WeatherUiModel'
import utils from '../utils/utils'
// 引入包名
import http from '@ohos.net.http';


@Entry
@Component
struct Index {
  @State isShowSideBar: boolean = false;
  @State selectCity: CityModel = { locationId: 101280601, locationName: '深圳' };
  @State weatherUiModel: WeatherUiModel = {
    nowTemp: 0,
    nowWeatherText: 0,
    tempMax: 0,
    tempMin: 0,
    category: 0,
    precip: 0,
    hourlyTemp: [],
    iconDays: [],
    date: '-月-日',
    day: '',
    dayArr: utils.getDayArr(),
    hoursArr: utils.getHoursArr(),
  };

  // 绘制界面
  build() {
    SideBarContainer(SideBarContainerType.Embed) {

      // 侧边栏
      SideBar({ selectCity: $selectCity, isShowSideBar: $isShowSideBar })

      if (this.isShowSideBar) {
        //灰底
        SideBarContentBac({ isShowSideBar: $isShowSideBar })
      } else {
        // 内容
        SideBarContent({ isShowSideBar: $isShowSideBar, selectCity: $selectCity, weatherUiModel: $weatherUiModel })
          .onClick(()=>{
            this.request()
          })
      }
    }
    .showControlButton(false)
    .showSideBar(this.isShowSideBar)
    .autoHide(false)
    .sideBarWidth(160)
    .width('100%')
  }

  request() {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
    // 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。 8+
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });
    httpRequest.request(
      // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
      "https://devapi.qweather.com/v7/weather/now?location="+this.selectCity.locationId+"&key=134465ee3fed4f938dcba94152526adb",
      {
        method: http.RequestMethod.GET, // 可选，默认为http.RequestMethod.GET
      }, (err: Error, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析
        console.info('Result:' + JSON.stringify(data.result));
        console.info('code:' + JSON.stringify(data.responseCode));
        // data.header为HTTP响应头，可根据业务需要进行解析
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + JSON.stringify(data.cookies)); // 8+
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy();
      } else {
        console.error('error:' + JSON.stringify(err));
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy();
      }
    }
    );
  }
}