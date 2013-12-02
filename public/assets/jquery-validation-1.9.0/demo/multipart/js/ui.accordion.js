/*
 * jQuery UI Accordion 1.7.1
 *
 * Copyright (c) 2009 AUTHORS.txt (http://jqueryui.com/about)
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * http://docs.jquery.com/UI/Accordion
 *
 * Depends:
 *	ui.core.js
 */
!function(e){e.widget("ui.accordion",{_init:function(){var t=this.options,n=this;if(this.running=0,t.collapsible==e.ui.accordion.defaults.collapsible&&t.alwaysOpen!=e.ui.accordion.defaults.alwaysOpen&&(t.collapsible=!t.alwaysOpen),t.navigation){var r=this.element.find("a").filter(t.navigationFilter);r.length&&(r.filter(t.header).length?this.active=r:(this.active=r.parent().parent().prev(),r.addClass("ui-accordion-content-active")))}this.element.addClass("ui-accordion ui-widget ui-helper-reset"),"UL"==this.element[0].nodeName&&this.element.children("li").addClass("ui-accordion-li-fix"),this.headers=this.element.find(t.header).addClass("ui-accordion-header ui-helper-reset ui-state-default ui-corner-all").bind("mouseenter.accordion",function(){e(this).addClass("ui-state-hover")}).bind("mouseleave.accordion",function(){e(this).removeClass("ui-state-hover")}).bind("focus.accordion",function(){e(this).addClass("ui-state-focus")}).bind("blur.accordion",function(){e(this).removeClass("ui-state-focus")}),this.headers.next().addClass("ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom"),this.active=this._findActive(this.active||t.active).toggleClass("ui-state-default").toggleClass("ui-state-active").toggleClass("ui-corner-all").toggleClass("ui-corner-top"),this.active.next().addClass("ui-accordion-content-active"),e("<span/>").addClass("ui-icon "+t.icons.header).prependTo(this.headers),this.active.find(".ui-icon").toggleClass(t.icons.header).toggleClass(t.icons.headerSelected),e.browser.msie&&this.element.find("a").css("zoom","1"),this.resize(),this.element.attr("role","tablist"),this.headers.attr("role","tab").bind("keydown",function(e){return n._keydown(e)}).next().attr("role","tabpanel"),this.headers.not(this.active||"").attr("aria-expanded","false").attr("tabIndex","-1").next().hide(),this.active.length?this.active.attr("aria-expanded","true").attr("tabIndex","0"):this.headers.eq(0).attr("tabIndex","0"),e.browser.safari||this.headers.find("a").attr("tabIndex","-1"),t.event&&this.headers.bind(t.event+".accordion",function(e){return n._clickHandler.call(n,e,this)})},destroy:function(){var e=this.options;this.element.removeClass("ui-accordion ui-widget ui-helper-reset").removeAttr("role").unbind(".accordion").removeData("accordion"),this.headers.unbind(".accordion").removeClass("ui-accordion-header ui-helper-reset ui-state-default ui-corner-all ui-state-active ui-corner-top").removeAttr("role").removeAttr("aria-expanded").removeAttr("tabindex"),this.headers.find("a").removeAttr("tabindex"),this.headers.children(".ui-icon").remove();var t=this.headers.next().css("display","").removeAttr("role").removeClass("ui-helper-reset ui-widget-content ui-corner-bottom ui-accordion-content ui-accordion-content-active");(e.autoHeight||e.fillHeight)&&t.css("height","")},_setData:function(t,n){"alwaysOpen"==t&&(t="collapsible",n=!n),e.widget.prototype._setData.apply(this,arguments)},_keydown:function(t){var n=this.options,r=e.ui.keyCode;if(!(n.disabled||t.altKey||t.ctrlKey)){var i=this.headers.length,a=this.headers.index(t.target),o=!1;switch(t.keyCode){case r.RIGHT:case r.DOWN:o=this.headers[(a+1)%i];break;case r.LEFT:case r.UP:o=this.headers[(a-1+i)%i];break;case r.SPACE:case r.ENTER:return this._clickHandler({target:t.target},t.target)}return o?(e(t.target).attr("tabIndex","-1"),e(o).attr("tabIndex","0"),o.focus(),!1):!0}},resize:function(){var t,n=this.options;if(n.fillSpace){if(e.browser.msie){var r=this.element.parent().css("overflow");this.element.parent().css("overflow","hidden")}t=this.element.parent().height(),e.browser.msie&&this.element.parent().css("overflow",r),this.headers.each(function(){t-=e(this).outerHeight()});var i=0;this.headers.next().each(function(){i=Math.max(i,e(this).innerHeight()-e(this).height())}).height(Math.max(0,t-i)).css("overflow","auto")}else n.autoHeight&&(t=0,this.headers.next().each(function(){t=Math.max(t,e(this).outerHeight())}).height(t))},activate:function(e){var t=this._findActive(e)[0];this._clickHandler({target:t},t)},_findActive:function(t){return t?"number"==typeof t?this.headers.filter(":eq("+t+")"):this.headers.not(this.headers.not(t)):t===!1?e([]):this.headers.filter(":eq(0)")},_clickHandler:function(t,n){var r=this.options;if(r.disabled)return!1;if(!t.target&&r.collapsible){this.active.removeClass("ui-state-active ui-corner-top").addClass("ui-state-default ui-corner-all").find(".ui-icon").removeClass(r.icons.headerSelected).addClass(r.icons.header),this.active.next().addClass("ui-accordion-content-active");var i=this.active.next(),a={options:r,newHeader:e([]),oldHeader:r.active,newContent:e([]),oldContent:i},o=this.active=e([]);return this._toggle(o,i,a),!1}var s=e(t.currentTarget||n),l=s[0]==this.active[0];if(this.running||!r.collapsible&&l)return!1;this.active.removeClass("ui-state-active ui-corner-top").addClass("ui-state-default ui-corner-all").find(".ui-icon").removeClass(r.icons.headerSelected).addClass(r.icons.header),this.active.next().addClass("ui-accordion-content-active"),l||(s.removeClass("ui-state-default ui-corner-all").addClass("ui-state-active ui-corner-top").find(".ui-icon").removeClass(r.icons.header).addClass(r.icons.headerSelected),s.next().addClass("ui-accordion-content-active"));var o=s.next(),i=this.active.next(),a={options:r,newHeader:l&&r.collapsible?e([]):s,oldHeader:this.active,newContent:l&&r.collapsible?e([]):o.find("> *"),oldContent:i.find("> *")},u=this.headers.index(this.active[0])>this.headers.index(s[0]);return this.active=l?e([]):s,this._toggle(o,i,a,l,u),!1},_toggle:function(t,n,r,i,a){var o=this.options,s=this;this.toShow=t,this.toHide=n,this.data=r;var l=function(){return s?s._completed.apply(s,arguments):void 0};if(this._trigger("changestart",null,this.data),this.running=0===n.size()?t.size():n.size(),o.animated){var u={};u=o.collapsible&&i?{toShow:e([]),toHide:n,complete:l,down:a,autoHeight:o.autoHeight||o.fillSpace}:{toShow:t,toHide:n,complete:l,down:a,autoHeight:o.autoHeight||o.fillSpace},o.proxied||(o.proxied=o.animated),o.proxiedDuration||(o.proxiedDuration=o.duration),o.animated=e.isFunction(o.proxied)?o.proxied(u):o.proxied,o.duration=e.isFunction(o.proxiedDuration)?o.proxiedDuration(u):o.proxiedDuration;var c=e.ui.accordion.animations,d=o.duration,h=o.animated;c[h]||(c[h]=function(e){this.slide(e,{easing:h,duration:d||700})}),c[h](u)}else o.collapsible&&i?t.toggle():(n.hide(),t.show()),l(!0);n.prev().attr("aria-expanded","false").attr("tabIndex","-1").blur(),t.prev().attr("aria-expanded","true").attr("tabIndex","0").focus()},_completed:function(e){var t=this.options;this.running=e?0:--this.running,this.running||(t.clearStyle&&this.toShow.add(this.toHide).css({height:"",overflow:""}),this._trigger("change",null,this.data))}}),e.extend(e.ui.accordion,{version:"1.7.1",defaults:{active:null,alwaysOpen:!0,animated:"slide",autoHeight:!0,clearStyle:!1,collapsible:!1,event:"click",fillSpace:!1,header:"> li > :first-child,> :not(li):even",icons:{header:"ui-icon-triangle-1-e",headerSelected:"ui-icon-triangle-1-s"},navigation:!1,navigationFilter:function(){return this.href.toLowerCase()==location.href.toLowerCase()}},animations:{slide:function(t,n){if(t=e.extend({easing:"swing",duration:300},t,n),!t.toHide.size())return t.toShow.animate({height:"show"},t),void 0;if(!t.toShow.size())return t.toHide.animate({height:"hide"},t),void 0;var r,i,a=t.toShow.css("overflow"),o={},s={},l=["height","paddingTop","paddingBottom"],u=t.toShow;i=u[0].style.width,u.width(parseInt(u.parent().width(),10)-parseInt(u.css("paddingLeft"),10)-parseInt(u.css("paddingRight"),10)-(parseInt(u.css("borderLeftWidth"),10)||0)-(parseInt(u.css("borderRightWidth"),10)||0)),e.each(l,function(n,r){s[r]="hide";var i=(""+e.css(t.toShow[0],r)).match(/^([\d+-.]+)(.*)$/);o[r]={value:i[1],unit:i[2]||"px"}}),t.toShow.css({height:0,overflow:"hidden"}).show(),t.toHide.filter(":hidden").each(t.complete).end().filter(":visible").animate(s,{step:function(e,n){"height"==n.prop&&(r=(n.now-n.start)/(n.end-n.start)),t.toShow[0].style[n.prop]=r*o[n.prop].value+o[n.prop].unit},duration:t.duration,easing:t.easing,complete:function(){t.autoHeight||t.toShow.css("height",""),t.toShow.css("width",i),t.toShow.css({overflow:a}),t.complete()}})},bounceslide:function(e){this.slide(e,{easing:e.down?"easeOutBounce":"swing",duration:e.down?1e3:200})},easeslide:function(e){this.slide(e,{easing:"easeinout",duration:700})}}})}(jQuery);