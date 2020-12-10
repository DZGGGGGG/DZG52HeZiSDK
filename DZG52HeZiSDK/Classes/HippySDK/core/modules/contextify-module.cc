/*
 *
 * Tencent is pleased to support the open source community by making
 * Hippy available.
 *
 * Copyright (C) 2019 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
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
 *
 */

#include "contextify-module.h"

#include <string.h>

#include <memory>
#include <string>

#include "logging.h"
#include "module-register.h"
#include "callback-info.h"
#include "js-native-api-types.h"
#include "js-native-api.h"
#include "native-source-code.h"

REGISTER_MODULE(ContextifyModule, RunInThisContext)

void ContextifyModule::RunInThisContext(const hippy::napi::CallbackInfo& info) {
  std::shared_ptr<Scope> scope = info.GetScope();
  std::shared_ptr<hippy::napi::Ctx> context = scope->GetContext();
  HIPPY_CHECK(context);

  std::string key;
  if (!context->GetValueString(info[0], &key)) {
    info.GetExceptionValue()->Set(
        context, "The first argument must be non-empty string.");
    return;
  }

  HIPPY_DLOG(hippy::Debug, "RunInThisContext key = %s", key.c_str());
  auto source_code = hippy::GetNativeSourceCode(key.c_str());
  std::shared_ptr<hippy::napi::CtxValue> ret = context->EvaluateJavascript(
      source_code.data_, source_code.length_, key.c_str());
  info.GetReturnValue()->Set(ret);
}
