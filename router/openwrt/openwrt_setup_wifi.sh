#!/bin/ash

################ YOUR CONFIG ################

SSID="OpenWrt"
DEFAULT_PASSWORD="23kl9cs@AA"
ROAMING_DOMAIN="b00b"

################ MAIN SCRIPT ################

uci set wireless.radio0.channel='auto'
uci set wireless.radio0.country='VN'
uci set wireless.radio0.cell_density='0'
uci set wireless.default_radio0.ssid=$SSID
uci set wireless.default_radio0.dtim_period='3'
uci set wireless.default_radio0.encryption='sae-mixed'
uci set wireless.default_radio0.key=$DEFAULT_PASSWORD
uci set wireless.default_radio0.ieee80211r='1'
uci set wireless.default_radio0.mobility_domain=$ROAMING_DOMAIN
uci set wireless.default_radio0.ft_over_ds='0'
uci set wireless.default_radio0.ft_psk_generate_local='1'

uci set wireless.radio1.channel='auto'
uci set wireless.radio1.country='VN'
uci set wireless.radio1.cell_density='0'
uci set wireless.default_radio1.ssid=$SSID
uci set wireless.default_radio1.dtim_period='3'
uci set wireless.default_radio1.encryption='sae-mixed'
uci set wireless.default_radio1.key=$DEFAULT_PASSWORD
uci set wireless.default_radio1.ieee80211r='1'
uci set wireless.default_radio1.mobility_domain=$ROAMING_DOMAIN
uci set wireless.default_radio1.ft_over_ds='0'
uci set wireless.default_radio1.ft_psk_generate_local='1'

uci commit
