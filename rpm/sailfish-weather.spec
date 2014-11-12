Name:       sailfish-weather
Summary:    Weather application
Version:    0.1
Release:    1
Group:      System/Applications
License:    TBD
URL:        https://bitbucket.org/jolla/ui-sailfish-weather
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(qdeclarative5-boostable)
BuildRequires:  qt5-qttools
BuildRequires:  qt5-qttools-linguist

Requires:  sailfishsilica-qt5
Requires:  sailfish-components-weather-qt5 >= 0.0.5
Requires:  mapplauncherd-booster-silica-qt5
Requires:  connman-qt5-declarative
Requires:  jolla-settings-system

%description
Sailfish-style Weather application

%package ts-devel
Summary: Translation source for %{name}

%description ts-devel
Translation source for %{name}

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5 sailfish-weather.pro
make %{_smp_mflags}

%install
rm -rf %{buildroot}

%qmake5_install

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%{_datadir}/sailfish-weather/*
%{_bindir}/sailfish-weather
%{_datadir}/translations/weather_eng_en.qm
%{_datadir}/jolla-settings/entries/sailfish-weather.json
%{_datadir}/jolla-settings/pages/sailfish-weather
%{_libdir}/qt5/qml/org/sailfishos/weather/settings

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/weather.ts
