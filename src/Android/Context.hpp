/*
Copyright_License {

  Top Hat Soaring Glide Computer - http://www.tophatsoaring.org/
  Copyright (C) 2000-2016 The Top Hat Soaring Project
  A detailed list of copyright holders can be found in the file "AUTHORS".

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}
*/

#ifndef XCSOAR_ANDROID_CONTEXT_HPP
#define XCSOAR_ANDROID_CONTEXT_HPP

#include "Java/Object.hxx"

class Context : public Java::Object {
public:
  Context(JNIEnv *env, jobject obj):Java::Object(env, obj) {
  }

  jobject GetSystemService(JNIEnv *env, jstring name);
  jobject GetSystemService(JNIEnv *env, const char *name);
  jobject GetVibrator(JNIEnv *env);

  /**
   * Wrapper for Context.getExternalFilesDir(null): the app-specific
   * directory on shared storage, which needs no permission and is
   * accessible via USB (Android/data/<package>/files).
   *
   * @return buffer on success, nullptr if unavailable
   */
  char *GetExternalFilesDir(JNIEnv *env, char *buffer, size_t max_size);
};

#endif
