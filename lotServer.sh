#!/bin/bash
#
# Original Author: MoeClub.org
#
# Modified by Aniverse

script_update=2020.05.08
script_version=r10013

usage_guide() {
    bash <(wget --no-check-certificate -qO- https://github.com/Aniverse/lotServer/raw/master/lotServer.sh) install
  # bash <(wget --no-check-certificate -qO- https://github.com/MoeClub/lotServer/raw/master/Install.sh)  uninstall
    /appex/etc/apx.lic
    bash /appex/bin/lotServer.sh start
    bash /appex/bin/lotServer.sh status
}

[[ $EUID -ne 0 ]] && { echo "ERROR: This script must be run as root!" ; exit 1 ; }

function pause() { echo ; read -p "Press Enter to Continue ..." INP ; }

mkdir -p /tmp
cd /tmp

function dep_check() {
    apt-get >/dev/null 2>&1
    [ $? -le '1' ] && apt-get -y -qq install sed grep gawk ethtool ca-certificates >/dev/null 2>&1
    yum >/dev/null 2>&1
    [ $? -le '1' ] && yum -y -q install sed grep gawk ethtool >/dev/null 2>&1
}

function acce_check() {
    local IFS='.'
    read ver01 ver02 ver03 ver04 <<<"$1"
    sum01=$[$ver01*2**32]
    sum02=$[$ver02*2**16]
    sum03=$[$ver03*2**8]
    sum04=$[$ver04*2**0]
    sum=$[$sum01+$sum02+$sum03+$sum04]
    [ "$sum" -gt '12885627914' ] && echo "1" || echo "0"
}

function generate_lic_local() {
    which php > /dev/null || apt-get install -y php-cli
    which php > /dev/null || yum install -y php-cli
    which php > /dev/null || Uninstall "Error! No php found"
    which git > /dev/null || apt-get install -y git
    which php > /dev/null || yum install -y git
    which git > /dev/null || Uninstall "Error! No git found"
    git clone https://github.com/Tai7sy/LotServer_KeyGen
    cd LotServer_KeyGen
    git checkout b9f13eb
    php keygen.php $Mac
    mv out.lic ${AcceTmp}/etc/apx.lic
    cd ..
    rm -rf LotServer_KeyGen
}

function generate_lic() {
    acce_ver=$(acce_check ${KNV})

    # [[ $(which php) ]] && Lic=local
    [[ -z $Lic ]] && Lic=a
    [[ $Lic == a ]] && LicURL="https://api.moeclub.org/lotServer?ver=${acce_ver}&mac=${Mac}" # https://moeclub.azurewebsites.net?ver=${acce_ver}&mac=${Mac}
    # https://github.com/MoeClub/lotServer/compare/master...wxlost:master
    [[ $Lic == b ]] && LicURL="https://118868.xyz/keygen.php?ver=${acce_ver}&mac=${Mac}"
    # https://github.com/MoeClub/lotServer/compare/master...Jack8Li:master
    [[ $Lic == c ]] && LicURL="https://backup.rr5rr.com/LotServer/keygen.php?ver=${acce_ver}&mac=${Mac}"
    # https://github.com/MoeClub/lotServer/compare/master...ouyangmland:master
    [[ $Lic == d ]] && LicURL="http://speedsvip.eu5.org/keygen.php?mac=${Mac}"
    # https://github.com/jmireles7/lotServer/commit/dae9c4f781cf8ae01c9934320c05105071518627
    [[ $Lic == e ]] && LicURL="http://104.167.103.163/keygen.php?ver=${acce_ver}&mac=${Mac}"
    # https://github.com/luopos/lotServer/commit/c035cdf5db2e48281829749b8caddcf41fe7d995
    [[ $Lic == f ]] && LicURL="http://key.vps.bi/keygen.php?ver=${acce_ver}&mac=${Mac}"
    # https://github.com/liulanyinghuo/lotServer/commit/27f98562182d19bce5a32c1355f949b0f06e5d8c
    [[ $Lic == g ]] && LicURL="https://020000.xyz/keygen.php?ver=${acce_ver}&mac=${Mac}"
    [[ $Lic =~ (a|b|c|d|e|f|g) ]] && wget -O "${AcceTmp}/etc/apx.lic" "$LicURL"
    [[ $Lic == local ]] && generate_lic_local

    [ "$(du -b ${AcceTmp}/etc/apx.lic |cut -f1)" -lt '152' ] && generate_lic_local
    [ "$(du -b ${AcceTmp}/etc/apx.lic |cut -f1)" -lt '152' ] && Uninstall "Error! I can not generate the Lic for you, Please try again later. "
    echo "Lic generate success! "
}

function Install()
{
  echo "Preparatory work... $script_version"
  Uninstall;
  dep_check;
  [ -f /etc/redhat-release ] && KNA=$(awk '{print $1}' /etc/redhat-release)
  [ -f /etc/os-release ] && KNA=$(awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release)
  [ -f /etc/lsb-release ] && KNA=$(awk -F'[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release)
  KNB=$(getconf LONG_BIT)
  [ ! -f /proc/net/dev ] && echo -ne "I can not find network device! \n\n" && exit 1;
  #Eth_List=`cat /proc/net/dev |awk -F: 'function trim(str){sub(/^[ \t]*/,"",str); sub(/[ \t]*$/,"",str); return str } NR>2 {print trim($1)}'  |grep -Ev '^lo|^sit|^stf|^gif|^dummy|^vmnet|^vir|^gre|^ipip|^ppp|^bond|^tun|^tap|^ip6gre|^ip6tnl|^teql|^venet' |awk 'NR==1 {print $0}'`
  #[ -z "$Eth_List" ] && echo "I can not find the server pubilc Ethernet! " && exit 1
  #Eth=$(echo "$Eth_List" |head -n1)
  #EthConfig=$(ip route get 8.8.8.8 | awk '{print $5}')
  #[ -z "$Eth" ] && Uninstall "Error! Not found a valid ether. "
  #[ -z "$EthConfig" ] && Uninstall "Error! Not found a valid ether for config. "

  [ -n "$(grep 'eth0:' /proc/net/dev)" ] && wangka1=eth0 || wangka1=`cat /proc/net/dev |awk -F: 'function trim(str){sub(/^[ \t]*/,"",str); sub(/[ \t]*$/,"",str); return str } NR>2 {print trim($1)}'  |grep -Ev '^lo|^sit|^stf|^gif|^dummy|^vmnet|^vir|^gre|^ipip|^ppp|^bond|^tun|^tap|^ip6gre|^ip6tnl|^teql|^venet|^he-ipv6|^docker' |awk 'NR==1 {print $0}'`
  wangka2=$(ip link show 2>1 | grep -i broadcast | grep -m1 UP  | cut -d: -f 2 | cut -d@ -f 1 | sed 's/ //g')
  if [[ -n $wangka2 ]]; then
      if [[ $wangka1 == $wangka2 ]];then
          Eth=$wangka1
      else
          Eth=$wangka2
      fi
  else
      Eth=$wangka1
  fi

  Mac=$(cat /sys/class/net/${Eth}/address)
  [ -z "$Mac" ] && Uninstall "Error! Not found mac code. "
  echo "Eth=$Eth"
  URLKernel='https://github.com/Aniverse/lotServer/raw/master/lotServer.log'
  AcceData=$(wget --no-check-certificate -qO- "$URLKernel")
  AcceVer=$(echo "$AcceData" |grep "$KNA/" |grep "/x$KNB/" |grep "/$KNK/" |awk -F'/' '{print $NF}' |sort -nk 2 -t '_' |tail -n1)
  MyKernel=$(echo "$AcceData" |grep "$KNA/" |grep "/x$KNB/" |grep "/$KNK/" |grep "$AcceVer" |tail -n1)
  [ -z "$MyKernel" ] && echo -ne "Kernel not be matched! \nYou should change kernel manually, and try again! \n\nView the link to get details: \n"$URLKernel" \n\n\n" && exit 1
  KNN=$(echo "$MyKernel" |awk -F '/' '{ print $2 }') && [ -z "$KNN" ] && Uninstall "Error! Not Matched. "
  KNV=$(echo "$MyKernel" |awk -F '/' '{ print $5 }') && [ -z "$KNV" ] && Uninstall "Error! Not Matched. "
  AcceRoot="/tmp/lotServer"
  AcceTmp="${AcceRoot}/apxfiles"
  AcceBin="acce-"$KNV"-["$KNA"_"$KNN"_"$KNK"]"
  mkdir -p "${AcceTmp}/bin/"
  mkdir -p "${AcceTmp}/etc/"
  wget --no-check-certificate -qO "${AcceTmp}/bin/${AcceBin}" "https://github.com/Aniverse/lotServer/raw/master/${MyKernel}"
  [ ! -f "${AcceTmp}/bin/${AcceBin}" ] && Uninstall "Download Error! Not Found ${AcceBin}. "
  wget --no-check-certificate -qO "/tmp/lotServer.tar" "https://github.com/Aniverse/lotServer/raw/master/lotServer.tar"
  tar -xvf "/tmp/lotServer.tar" -C /tmp
  generate_lic
  sed -i "s/^accif\=.*/accif\=\"$Eth\"/" "${AcceTmp}/etc/config"
  sed -i "s/^apxexe\=.*/apxexe\=\"\/appex\/bin\/$AcceBin\"/" "${AcceTmp}/etc/config"
  bash "${AcceRoot}/install.sh" -in 1000000 -out 1000000 -t 0 -r -b -i ${Eth}
  rm -rf /tmp/*lotServer* >/dev/null 2>&1
  if [ -f /appex/bin/serverSpeeder.sh ]; then
    bash /appex/bin/serverSpeeder.sh status
  elif [ -f /appex/bin/lotServer.sh ]; then
    bash /appex/bin/lotServer.sh status
  fi
  exit 0
}

function Uninstall()
{
  AppexName="lotServer"
  [ -e /appex ] && chattr -R -i /appex >/dev/null 2>&1
  if [ -d /etc/rc.d ]; then
    rm -rf /etc/rc.d/init.d/serverSpeeder >/dev/null 2>&1
    rm -rf /etc/rc.d/rc*.d/*serverSpeeder >/dev/null 2>&1
    rm -rf /etc/rc.d/init.d/lotServer >/dev/null 2>&1
    rm -rf /etc/rc.d/rc*.d/*lotServer >/dev/null 2>&1
  fi
  if [ -d /etc/init.d ]; then
    rm -rf /etc/init.d/*serverSpeeder* >/dev/null 2>&1
    rm -rf /etc/rc*.d/*serverSpeeder* >/dev/null 2>&1
    rm -rf /etc/init.d/*lotServer* >/dev/null 2>&1
    rm -rf /etc/rc*.d/*lotServer* >/dev/null 2>&1
  fi
  rm -rf /usr/lib/systemd/system/lotserver.service >/dev/null 2>&1
  rm -rf /etc/lotServer.conf >/dev/null 2>&1
  rm -rf /etc/serverSpeeder.conf >/dev/null 2>&1
  [ -f /appex/bin/lotServer.sh ] && AppexName="lotServer" && bash /appex/bin/lotServer.sh uninstall -f >/dev/null 2>&1
  [ -f /appex/bin/serverSpeeder.sh ] && AppexName="serverSpeeder" && bash /appex/bin/serverSpeeder.sh uninstall -f >/dev/null 2>&1
  rm -rf /appex >/dev/null 2>&1
  rm -rf /tmp/*${AppexName}* >/dev/null 2>&1
  [ -n "$1" ] && echo -ne "$AppexName has been removed! \n" && echo "$1" && echo -ne "\n\n\n" && exit 0
}

function UsageE() { echo -ne "Usage:\n     bash $0 [install |uninstall |install '{Kernel Version}']\n" ; }

if [ $# == '1' ]; then
    [ "$1" == 'install' ] && KNK="$(uname -r)" && Install && Usage=No
    [ "$1" == 'uninstall' ] && Uninstall "Done." && Usage=No
    [[ $Usage != No ]] && UsageE
elif [ $# == '2' ]; then
    [ "$1" == 'install' ] && KNK="$2" && Install && Usage=No
    [ "$1" == 'I' ] && Lic=$2 && [[ $Lic =~ (a|b|c|d|e|f|g|local) ]] && KNK="$(uname -r)" && Install && Usage=No
    [[ $Usage != No ]] && UsageE
elif [ $# == '3' ]; then
    [ "$1" == 'I' ] && Lic=$3 && [[ $Lic =~ (a|b|c|d|e|f|g|local) ]] && KNK="$2" && Install && Usage=No
    [[ $Usage != No ]] && UsageE
else
    UsageE
fi
