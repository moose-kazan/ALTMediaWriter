/*
 * ALT Media Writer
 * Copyright (C) 2016-2019 Martin Bříza <mbriza@redhat.com>
 * Copyright (C) 2020-2022 Dmitry Degtyarev <kevl@basealt.ru>
 *
 * ALT Media Writer is a fork of Fedora Media Writer
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import MediaWriter 1.0

import "../simple"

Dialog {
    id: root
    title: drives.lastRestoreable ? qsTr("Restore %1?").arg(drives.lastRestoreable.name) : ""

    Connections {
        target: drives
        function onLastRestoreableChanged() {
            if (drives.lastRestoreable == null) {
                root.close()
            }
        }
    }

    contentItem : Rectangle {
        id: mainItem
        focus: true
        implicitWidth: 480
        implicitHeight: textItem.height + buttonItem.height + 48
        height: textItem.height + buttonItem.height + 48
        color: palette.window

        Keys.onEscapePressed: {
            if (drives.lastRestoreable.restoreStatus != Drive.RESTORING) {
                root.close()
            }
        }

        Item {
            id: wrapper
            anchors.fill: parent
            anchors.margins: 18
            Row {
                id: textItem
                spacing: 36
                height: warningText.height
                Text {
                    id: warningText
                    visible: mainItem.state == "contains_live"
                    width: wrapper.width
                    text: qsTr("<p align=\"justify\">To reclaim all space available on the drive, it has to be restored to its factory settings. The live system and all saved data will be deleted.</p><p align=\"justify\">You don't need to restore the drive if you want to write another live system to it.</p><p align=\"justify\">Do you want to continue?</p>")
                    textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pointSize: 9
                    color: palette.windowText
                }
                ColumnLayout {
                    id: progress
                    visible: mainItem.state == "restoring"
                    width: wrapper.width
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12
                    Item {
                        width: 1; height: 1
                    }

                    AdwaitaBusyIndicator {
                        id: progressIndicator
                        width: 256
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: wrapper.width
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr("<p align=\"justify\">Please wait while ALT Media Writer restores your portable drive.</p>")
                        font.pointSize: 9
                        color: palette.windowText
                    }
                }
                ColumnLayout {
                    visible: mainItem.state == "restored"
                    width: wrapper.width
                    anchors.verticalCenter: parent.verticalCenter
                    CheckMark {
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: wrapper.width
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Your drive was successfully restored!")
                        font.pointSize: 9
                        color: palette.windowText
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }
                ColumnLayout {
                    visible: mainItem.state == "restore_error"
                    width: wrapper.width
                    anchors.verticalCenter: parent.verticalCenter
                    Cross {
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Unfortunately, an error occurred during the process.<br>Please try restoring the drive using your system tools.")
                        font.pointSize: 9
                        color: palette.windowText
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }
            }

            Row {
                id: buttonItem
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                spacing: 12
                AdwaitaButton {
                    text: qsTr("Cancel")
                    visible: (mainItem.state == "contains_live" || mainItem.state == "restoring")
                    onClicked: root.visible = false
                }
                AdwaitaButton {
                    text: drives.lastRestoreable && drives.lastRestoreable.restoreStatus == Drive.CONTAINS_LIVE ? qsTr("Restore") : qsTr("Close")
                    color: drives.lastRestoreable && drives.lastRestoreable.restoreStatus == Drive.CONTAINS_LIVE ? "red" : "#628fcf"
                    textColor: "white"
                    enabled: !drives.lastRestoreable || drives.lastRestoreable.restoreStatus != Drive.RESTORING
                    onClicked: {
                        if (drives.lastRestoreable && drives.lastRestoreable.restoreStatus == Drive.CONTAINS_LIVE) {
                            drives.lastRestoreable.restore()
                        } else {
                            root.visible = false
                        }
                    }
                }
            }
        }

        states: [
            State {
                name: "contains_live"
                when: (drives.lastRestoreable && drives.lastRestoreable.restoreStatus == Drive.CONTAINS_LIVE)
            },
            State {
                name: "restoring"
                when: (drives.lastRestoreable && drives.lastRestoreable.restoreStatus == Drive.RESTORING)
            },
            State {
                name: "restored"
                when: (drives.lastRestoreable && drives.lastRestoreable.restoreStatus == Drive.RESTORED)
            },
            State {
                name: "restore_error"
                when: (drives.lastRestoreable && drives.lastRestoreable.restoreStatus == Drive.RESTORE_ERROR)
            }
        ]
    }
}
