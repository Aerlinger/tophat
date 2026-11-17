/* Copyright_License {

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

package org.tophat;

import android.app.Service;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import android.os.Binder;
import android.util.Log;

/**
 * All this Service implementation does is put itself in foreground.
 * It shall reduce the risk of getting killed by the Android Activity
 * Manager, because foreground services will only be killed under
 * extreme pressure.  Since this services runs in-process, Android
 * will also not terminate our main Activity.
 *
 * XCSoar needs high reliability, because it usually runs in
 * foreground as the only active application and should not be killed
 * by an incoming phone call.
 *
 * This is bad style for general-purpose Android apps, don't imitate
 * unless you have an excuse as good as ours ;-)
 */
public class MyService extends Service {
  private static final String TAG = "TopHat";
  private static final String CHANNEL_ID = "running";

  /**
   * Hack: this is set by onCreate(), to support the "testing"
   * package.
   */
  protected static Class mainActivityClass;

  private NotificationManager notificationManager;

  @Override public void onCreate() {
    if (mainActivityClass == null)
      mainActivityClass = XCSoar.class;

    super.onCreate();

    notificationManager = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);
  }

  private void onStart() {
    /* add an icon to the notification area while XCSoar runs, to
       remind the user that we're sucking his battery empty */
    Intent intent2 = new Intent(this, mainActivityClass);
    int piFlags = Build.VERSION.SDK_INT >= 23 ? PendingIntent.FLAG_IMMUTABLE : 0;
    PendingIntent contentIntent =
      PendingIntent.getActivity(this, 0, intent2, piFlags);

    Notification.Builder builder;
    if (Build.VERSION.SDK_INT >= 26) {
      NotificationChannel channel =
        new NotificationChannel(CHANNEL_ID, "Top Hat running",
                                NotificationManager.IMPORTANCE_LOW);
      notificationManager.createNotificationChannel(channel);
      builder = new Notification.Builder(this, CHANNEL_ID);
    } else {
      builder = new Notification.Builder(this);
    }

    Notification notification = builder
      .setSmallIcon(R.drawable.notification_icon)
      .setContentTitle("TopHat")
      .setContentText("Top Hat is running")
      .setContentIntent(contentIntent)
      .setOngoing(true)
      .build();

    try {
      if (Build.VERSION.SDK_INT >= 29)
        startForeground(1, notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION);
      else
        startForeground(1, notification);
    } catch (RuntimeException e) {
      /* Android 14+ refuses a "location" foreground service without
         location permission; keep running as a plain service */
      Log.w(TAG, "startForeground() failed", e);
    }
  }

  @Override public void onStart(Intent intent, int startId) {
    /* used by API level 4 (Android 1.6) */

    onStart();
  }

  @Override public int onStartCommand(Intent intent, int flags, int startId) {
    /* used by API level 5 (Android 2.0 and newer) */

    onStart();

    /* We want this service to continue running until it is explicitly
       stopped, so return sticky */
    return START_STICKY;
  }

  @Override public void onDestroy() {
    super.onDestroy();

    notificationManager.cancel(1);
  }

  @Override public IBinder onBind(Intent intent) {
    return null;
  }
}
