/*
 * Fedora Media Writer
 * Copyright (C) 2016 Martin Bříza <mbriza@redhat.com>
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

#ifndef RELEASEMANAGER_H
#define RELEASEMANAGER_H

#include <QSortFilterProxyModel>
#include <QStandardItemModel>
#include <QQmlListProperty>

class Release;
class ReleaseModel;
class QStandardItemModel;

/*
 * Architecture - singleton (x86, x86_64, etc)
 *
 * Release -> Version -> Variant
 *
 * Server  -> 24      -> Full    -> x86_64
 *                               -> i686
 *                    -> Netinst -> x86_64
 *                               -> i686
 *         -> 23      -> Full    -> x86_64
 *                               -> i686
 *                    -> Netinst -> x86_64
 *                               -> i686
 *
 * Variant can be downloaded.
 * Variant can be written to a drive - that's handled by the target drive object itself.
 *
 * There should be no platform-dependent code in this file nor in potential child classes.
 */


/**
 * @brief The ReleaseManager class
 *
 * The main entry point to access all the available releases.
 *
 * It is a QSortFilterProxyModel - that means the actual release data has to be provided first by the @ref ReleaseListModel .
 *
 * @property frontPage is true if the application is on the front page
 * @property downloadingMetadata is true while downloading metadata and false once it's finished
 * @property filterArchitecture index of the currently selected architecture
 * @property filterText user-entered text filter
 * @property selected the currently selected release
 * @property selectedIndex the index of the currently selected release
 * @property architectures the list of the available architectures
 * @property fileNameFilters image type filters for file dialog
 */
class ReleaseManager : public QSortFilterProxyModel {
    Q_OBJECT
    Q_PROPERTY(bool frontPage READ frontPage WRITE setFrontPage NOTIFY frontPageChanged)
    Q_PROPERTY(bool downloadingMetadata READ downloadingMetadata NOTIFY downloadingMetadataChanged)

    Q_PROPERTY(int filterArchitecture READ filterArchitecture WRITE setFilterArchitecture NOTIFY filterArchitectureChanged)
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)

    Q_PROPERTY(Release* selected READ selected NOTIFY selectedChanged)
    Q_PROPERTY(int selectedIndex READ selectedIndex WRITE setSelectedIndex NOTIFY selectedChanged)

    Q_PROPERTY(QStringList architectures READ architectures CONSTANT)
    Q_PROPERTY(QStringList fileNameFilters READ fileNameFilters CONSTANT)
public:
    explicit ReleaseManager(QObject *parent = 0);
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

    Q_INVOKABLE Release *get(int index) const;

    bool downloadingMetadata() const;

    bool frontPage() const;
    void setFrontPage(bool o);

    QString filterText() const;
    void setFilterText(const QString &o);

    QStringList architectures() const;
    QStringList fileNameFilters() const;
    int filterArchitecture() const;
    void setFilterArchitecture(int o);

    Release *selected() const;
    int selectedIndex() const;
    void setSelectedIndex(int o);

signals:
    void downloadingMetadataChanged();
    void frontPageChanged();
    void filterTextChanged();
    void filterArchitectureChanged();
    void selectedChanged();

private:
    ReleaseModel *m_sourceModel;
    bool m_frontPage;
    QString m_filterText;
    int m_filterArchitecture;
    int m_selectedIndex;
    bool m_downloadingMetadata;

    void loadVariants(const QString &variantsFile);
    void setDownloadingMetadata(const bool value);
    void downloadMetadata();
    void loadReleases(const QList<QString> &sectionsFiles);
    void addReleaseToModel(const int index, Release *release);
};

class ReleaseModel final : public QStandardItemModel {
public:
    using QStandardItemModel::QStandardItemModel;

    QHash<int, QByteArray> roleNames() const override;
};

#endif // RELEASEMANAGER_H
