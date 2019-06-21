// Copyright (c) 2014-2018 Crown Core developers
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef CROWN_PLATFORM_NF_TOKEN_REG_TX_BUILDER_H
#define CROWN_PLATFORM_NF_TOKEN_REG_TX_BUILDER_H

#include "utilstrencodings.h"
#include "rpcserver.h"
#include "platform/platform-utils.h"
#include "platform/rpc/specialtx-rpc-utils.h"
#include "nf-token-reg-tx.h"

namespace Platform
{
    class NfTokenRegTxBuilder
    {
    public:
        NfTokenRegTxBuilder & SetTokenProtocol(const json_spirit::Value & tokenProtocolId)
        {
            m_nfToken.tokenProtocolId = StringToProtocolName(tokenProtocolId.get_str().c_str());
            return *this;
        }

        NfTokenRegTxBuilder & SetTokenId(const json_spirit::Value & tokenIdHexValue)
        {
            m_nfToken.tokenId = ParseHashV(tokenIdHexValue.get_str(), "nfTokenId");
            return *this;
        }

        NfTokenRegTxBuilder & SetTokenOwnerKey(const json_spirit::Value & tokenOwnerKeyOrAddress, CKey & ownerPrivKey)
        {
            ownerPrivKey = ParsePrivKeyOrAddress(tokenOwnerKeyOrAddress.get_str());
            m_nfToken.tokenOwnerKeyId = ownerPrivKey.GetPubKey().GetID();
            return *this;
        }

        NfTokenRegTxBuilder & SetMetadataAdminKey(const json_spirit::Value & metadataAdminAddress)
        {
            if (!metadataAdminAddress.get_str().empty() && metadataAdminAddress.get_str() != "0")
            {
                m_nfToken.metadataAdminKeyId = ParsePubKeyIDFromAddress(metadataAdminAddress.get_str(), "nfTokenMetadataAdminAddr");
            }
            return *this;
        }

        NfTokenRegTxBuilder & SetMetadata(const json_spirit::Value & metadata)
        {
            //TODO: if binary then also convert from base64
            // if (protocol metadata is embedded -> read directly from the value)
            // else download metadata from uri
            // Note: supports embedded "text/plain" only for now
            m_nfToken.metadata.assign(metadata.get_str().begin(), metadata.get_str().end());
            return *this;
        }

        NfTokenRegTx BuildTx()
        {
            if (m_nfToken.metadataAdminKeyId.IsNull())
            {
                m_nfToken.metadataAdminKeyId = m_nfToken.tokenOwnerKeyId;
            }
            NfTokenRegTx regTx(std::move(m_nfToken));
            //regTx.Sign(m_ownerKey, m_ownerPubKey);
            return regTx;
        }

    private:
        NfToken m_nfToken;
        //CKey m_ownerKey;
        //CPubKey m_ownerPubKey;
    };
}

#endif // CROWN_PLATFORM_NF_TOKEN_REG_TX_BUILDER_H