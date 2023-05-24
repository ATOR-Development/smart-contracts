job "deploy-relay-registry" {
    datacenters = ["ator-fin"]
    type = "batch"

    reschedule {
        attempts = 0
    }

    task "deploy-relay-registry-task" {
        driver = "docker"

        config {
            image = "ghcr.io/ator-development/smart-contracts:0.0.5"
            entrypoint = ["npm"]
            command = "run"
            args = ["deploy"]
            volumes = [
                "local/relay-registry-init-state.json:/usr/src/app/smartweave/dist/contracts/relay-registry-init-state.json"
            ]
        }

        vault {
            policies = ["relay-registry-stage"]
        }

        template {
            data = <<EOH
            {{with secret "kv/relay-registry/stage"}}
                DEPLOYER_PRIVATE_KEY="{{.Data.data.RELAY_REGISTRY_OWNER_KEY}}"
            {{end}}
            EOH
            destination = "secrets/file.env"
            env         = true
        }

        template {
            data = <<EOH
{
    "claims":{},
    "verified":{
        "05532D97C632B62DF89E783BBF0A02BB2A192179":"0x8343541e84d3994DCfE77fcFf779E96E58E23e5F",
        "082A9668B82BC67DAB81819F5B1C9F5A48049FB3":"0x7b24318F2E4E2a4F68d2c03C020f399f7c92011c",
        "094F7556A5F07F5662C9E4EFA6CD9D41A2D5B29F":"0xa4B70e53F4868A18d9a386e01918039CccCB5b98",
        "09DC138DAEDD1CC461950E9FAA7779586E429974":"0x4e6585c9553842C448C5B9a6F2907E3AC2e87239",
        "0B72FE559B08D65B9ED64936EB52D28DD2C12B4D":"0x98Ed3B4B81AC60F8f23F47811BA52d0a3de7F081",
        "0C7C783A1B8CA59C6E7336F0CA3686DC20E7C8DC":"0xdB13f6F9BccF5ac30378Ea6DfBCA45eec35AfA33",
        "0DE9BB713F628E5AAC0300B7C4CD5365589B4DFC":"0x79B4E22F291d18116B70199C62A8c360ad248c93",
        "123B0957B74759A3AF6524E257E29D3708109B1B":"0x7E0781f0e035a16F5F3cf833d99D69E1e0036039",
        "17DA905ADD643D74A2213229C2DDD65C5DEAD8AE":"0x3941578e47Bcb7AC5f006488De8D0CA8461bB0b5",
        "192329D17E32F62C9C79D7386AC5B9890FDC9D0C":"0x9Cb10817CAe852C45D8D602097a76a932f6185E6",
        "1A82EB4EB4768102F706FD2A6ED466D068CE3F9E":"0x54a1354F615D464F7739d515598DB4e6315Ddc4B",
        "1CBB8CF10565C007861B66B5764FD88DF6F850BB":"0xb2A35680dB7dAe518b058213B629d7a8658163b9",
        "1CC8501EF03C3006A9DA76BA0D15ECC7FA8C34E8":"0x9aDE33Cf4ca08E46c7f84f82A82FCF5d8A4adA55",
        "20BA368772D88F21B9B10BA598068DBF719D6C44":"0xD9B42068EFa61f19eF4E02CbC6Ec0C54b4e3f479",
        "25280148FEF4E800FD179082D9E23276C7199E9D":"0xa2AA87bE9FaaE25F1aC6E6846eC9589b03625ce0",
        "25EDE81A1550F7072636C6A9D1485F75A9C60458":"0xf2948eDD428305D28DcBd6C284470e3823ee182b",
        "284C217B14811520C0586CFACEAA984ADA6C1F88":"0x172253954c395832a9e264FbD8f248221d4a92B6",
        "2CAC5BA69A56809C6F6D71A34929B2FF8C35CA9B":"0xDD3A2390CeFa80c1eCF5771636A4F49F2B8956C8",
        "342066443F2AFA27F0E515DAFBCBD0510957F7F5":"0xc93473826F40100aE06E2E02F351C30c7f985bf7",
        "36F9DF56CE9CC42466D7B6E5DAF22BEC40756B5C":"0x5dda24beBeD6031D08D8DF4B5Ae54b1e8FE88e6a",
        "405B3563D5393E24C3CAACF9E299A11AA8B0671E":"0x53731C988E8dD4013cDc0D848Fd18f565141B400",
        "40970B5B9C3FA1CE3293BD4826256CF488865B39":"0x9E18437AD074B1cf1B72C50fD7e060d7Df71915B",
        "42449D01D4052169541A3315F18179EAB8F923A9":"0x3ceb890224dAaB095745d3fa18e17F83699705ad",
        "4423B4748F312C60A04B0B89D6A7E03634521BB7":"0xFF391FEB9094EE5454eB73e0B3785D59730668f1",
        "4AE8B398D5C2C1F4AED80AF99F519F8274295798":"0x586bAB70B10d50Dd1aF1C200E47e3a368B7bE3ce",
        "51DA31A6EC1B33AA087BCE11B169178547BF470F":"0x54a1354F615D464F7739d515598DB4e6315Ddc4B",
        "54790AF4A4EF9EBDE7D7DE834E09562B7A915156":"0x79B4E22F291d18116B70199C62A8c360ad248c93",
        "59D9D32B3F650CA02DFCA69DB64CC0EDD4973784":"0x6BdF570Bfa23469E050E4deb7154fea4f36c0eb8",
        "5B765D3A887033AE487817090BF87C65B4536F6D":"0x0A393A0dFc3613eeD5Bd2A0A56d482351f4e3996",
        "5F4B3CCFBF1CE7268DE704E817B6D887C8E84AA5":"0x79E85c7Aa3C289021048B598Be347e3F5CF1F3B7",
        "60CCE755BD6B7410C70A16B4204D13A986437FDA":"0xa2AA87bE9FaaE25F1aC6E6846eC9589b03625ce0",
        "6165EBEB3F76E843E8E568DD3C0E7EA97C99DCED":"0x1cfAda52854e07371D7212ce4a80751828594f6a",
        "69C5A55DBA5724290689644F42A8DC129503F5DF":"0xA8790E0f56AECa3B550A52E0f8dbD171718Cd3B2",
        "6AAFCA940AF45837A312034ED84AADC081520DB1":"0x7Fa0963a8CB41d12C0bBa4286141dd71Ba158F44",
        "6C3390A5D5B1FCB1F2C132DCEF8DDACEAB4C6CB1":"0x5FC599567CDdD85a04F2789BFED8602F8065ABAC",
        "6D6A78A9DEB46FC4911FEEE3FD0384FB09225B10":"0x4ff2Edb4076830b3f6Aa538B09bCA861f63Eab29",
        "6EFF5149ECC089638F5A3ECBDACACB31B0219E09":"0xf27dB164e0EAA0d0419D44323d1AA79e122988E3",
        "70003522A2178F4FA21C55DAD1C8CF0345BA27DB":"0xd45d35bC22c19a9979184fC146108eaB0B6AD41c",
        "70D1EB563BBB10F1EE62E537BB9F3BD7419EE11E":"0x4768acafFB3aCd3D8Ae4798d423088F8366Bd8Ca",
        "7588BD9451FAC3AFADE97B31C0C1DC017F9DB2C3":"0x4ED816a923c4D9CEF68002642b08120083E076FB",
        "7A3D6ECE5C38D65F9022FDBE8F36A7C794B3661E":"0xA0f166b408316C01c778Ea51A35991CbeD0630B2",
        "7E52E9D36C6EF42F7A9F1B2B39B84CA24EA8E4D9":"0x1B64D3Bd427f36e2860716820ACE9D64CEE85547",
        "7E87FACC9F2D502C5D92EC32B3A78F75232FF9F9":"0xa6458774ceD3af1A705b6466F01f5EbF8F1bd661",
        "7F54724CB9E0567BC4A538556DF25A4FD6DC7F5E":"0xf2948eDD428305D28DcBd6C284470e3823ee182b",
        "80091027A368B886658AA0A89A75FBDE0BF7A5BC":"0xCd5D478686c6fA5E47Fc457F16E04224cD012690",
        "8129FD4C085A9F9BDEE1330BD32CE2B8B14DC8A2":"0x6c8C7a143792eDC723A2eA27B1c3f2235882189d",
        "87B569D9DB1B812944CFBF41DE696B1E6A2F62DD":"0x778B01147C894C76909D9C889e8F9e0D55328FA9",
        "8C6F44DF49DA4AB4BD254ED1CD2F391FA9BC66F8":"0x52285B51Fb4E0Ac159AC46aD12Ef792E02cD214d",
        "8C9ADE699D1923728893A16657D8299EC3084992":"0x555eBA6E5A1A848DA4d1B04946B679A07BBdB3AC",
        "8D543BCFCC18BF2189DE740D95F70B25EBA3BB0C":"0xDd29C85d9FDe419dcaF7cB3eCba603f1328eeF32",
        "8E1A82EDB2CFE72E765C98F1FE810539F8B8FC1A":"0xe3e34172823cf2E7F03CC2474758A0A4aefa2506",
        "8EADCF09FC8F816BB2C8F7F7B3D4CBDDF4C7DDFE":"0xBEd5edF3A75F1c132fd913006CD9840D288d2cA9",
        "9607723EA326414B57940E5695AC37F0956E8BC9":"0x9b38E17c23673471547d8b031e0EFebB666C985A",
        "98D05C6209E88A45E55AE1A9BF983BF2906AF54E":"0x2eF461FdBEcc607d0b0cA27106C683a8F64468A4",
        "990A2D419C4100954EA3E329DA39BBA6B866A74A":"0x5261b4A50F081b65b8f02C7e4388C2086B064236",
        "9AAF00DBD867A8312E54B2ADC4177B1707D25794":"0xa6458774ceD3af1A705b6466F01f5EbF8F1bd661",
        "9BA30444BC2C42EAD4542E031904B0CDA677A366":"0x180401CaBa07a348FaA85E138d7B7BeD24d79775",
        "9C8EFE139C445174069E6D2542ED884D7B5448B9":"0x4e6585c9553842C448C5B9a6F2907E3AC2e87239",
        "9CED2F3B8196D66BE1220185F0DED44C0FB90291":"0xc7b4bE28e73481e968934CF085b8f1d406688833",
        "9D1D415000C0E3CCAF64C282541C1CA0710F1660":"0x6F46735673bbBE1Ff346B1a0Aa45fd2B611216dB",
        "A30C4C285B182A5B8D6DE27E3F425835D21780A5":"0x41f171ffBfe44a3674bF9f30B47693b9bc62E9b7",
        "A3289048EF75669242A2DE6212D4307CDE211520":"0x43420789E9C75CBa5375d401f74c1cAB186d6D15",
        "A5CB3F546D4AC98B4A59131690E4A583B9D8851E":"0x2c1A5e2ca4d585d4d863d7b3f4ee6ba02B466dcf",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA":"0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        "ADE33C3288B9D754BC0EE7FA49036309639F05DE":"0x72724e620586e440253cB8579A0B28ef9487b039",
        "B0D745A63E20214DD3B0F551D3A10D14D66616FE":"0x5B5378870b6A52588e65c914a487F083a2193281",
        "B0DA63A0E893B85877B6A0190E0280F12F4CBEA2":"0x90057271e03ED6737B5A52A0CbD2239Aea811f94",
        "BC14319205C5BDF45282C830E0CEB6B3C53D62B1":"0x1DfC09e0Aef1d576edfa4fFD71FC4cAeaC911d4E",
        "BCCA31EC30093D0FA657A75A4FEB559473FDDD50":"0x887b7E335f75E69ecaf1376F057667562269d7DC",
        "BF4EB653F28CF9C958C3232D54B1FC29B4B12F17":"0x77B789133012751720cF50781d31Bb56Fb4B97dA",
        "BF70C16886ED6D70E1E103566314359AD95AA660":"0x688143644F42A247DE67bfAD8fB9FBFBbA7Ee021",
        "C109B67B7C4A08B13EDB3EBB0CF317E72B6716FD":"0x98Ed3B4B81AC60F8f23F47811BA52d0a3de7F081",
        "C38E150919A7C01D4849E0782AD2D8C4A74EAB34":"0xf2948eDD428305D28DcBd6C284470e3823ee182b",
        "CF14AC60C0DB1C4331E5E93314EBD23B96B11A31":"0x72724e620586e440253cB8579A0B28ef9487b039",
        "CF66C81AB64ACA1EC95E1F10B75721F4DE0AEE57":"0x4dCDb1BEa466136C287D1C522db829571F93b62f",
        "D40ACFCA44CAFB6DEE053F0CB18CD40D1232C780":"0x3eF27C8EEe8261fb5906B2e40daEDFC8E7B3f055",
        "D53735422CB4036A80F91837B7EE9747F5B5C9F1":"0xf4743bf3d7Aa0Cd2d6f2a5fB634B401D8db60987",
        "D60941A928090AADF96AD6481B974D79AA6048E2":"0xd045A4344362A3CD187bd7e2277Fae8BA067EFd5",
        "D87507E1F107F84FDE784EEF17E6F610EB2176A1":"0x9454d413886A3737c06b10dE11360669C56D5f24",
        "DBC2D22FFB25E6E2F054E562772DAE4CE61D5A4D":"0x8ce3456193Eabc7fa2Cd6f3660CA6eBf9f69E63b",
        "DEE60B40AE194A1731FC5104C4825948EB60A9CF":"0x4e6585c9553842C448C5B9a6F2907E3AC2e87239",
        "E47DADDAC2A5EC1E5851AA65802180429817B3F4":"0x39f438BbB019Ea3Ab114b2c42064efB1b389b89e",
        "E616E560EB2F9E380C7DE8506D8EB075517E76DA":"0xa3EE387E97fbeC75A2623A809726c38f6ac19B2D",
        "E6CFF9FD7ACFF8015604931A134AB66A1AE72E8A":"0xf2948eDD428305D28DcBd6C284470e3823ee182b",
        "E7D161A93D2FCFAF53CA35B9AB07F734ECC7D5B5":"0x9DCA83E91041222D20c491F5b25ddC7Ac79Ee53B",
        "E96BA73676476F68DCCDE99A383E114A33432B04":"0xF8Ae447F48af3748d64C509B20Be78C512292DB1",
        "EA50D08EC10EE837B8A1719AC4447547712EDB66":"0x7f85F0E167Cc229A7eB9B41221D9D8a7965f2949",
        "EE83DD28254EE2DE0AF8E45BB6C5449B056EF4D9":"0xe1aF18F9e5810A80365Ae7B89919540c01184dAc",
        "F080167CEC9667F54BF51BC0B31C5314E9C2A63F":"0x283C184c920102372b5FCD94807675D50A74e668",
        "F14F5730747ACC3F9E7F4D13EEE2059DAFED7CC9":"0x493e5f463feB5B13259214E81cF229c5B28303EC",
        "F6E2B85D48B9D38C1C8EB19A938EADC822902E94":"0x2Edd67E13e1e84337A8D0E908Eae83091Bd54945",
        "F94A6BE3AEBB1892674D6A14B708026A734200B8":"0x7bDAE3be9CB620822C576af1fD437056131E341a",
        "F94D6191BA227409F520483FEB2965BEB277B74D":"0x96f3F2f5Ca72863605B2977a26Aff2B86C4e19D6",
        "FA266D7B780F5052747DAC15A990FE3DFB5063EA":"0x22e2AA15d09A30Df7AF620D119806Aec826a55A7",
        "FA3DB534B688D91FE2E8E0215B7714C0C33012BB":"0xc60048Fd2bccd82da8A1C0d06B3CF1Bfd7D740A2",
        "FAE2B62C2A081FB5F6959773E7DD7068C3A8C822":"0x32c4e3A20c3fb085B4725fcF9303A450e750602A"
    }
}
            EOH
            destination = "local/relay-registry-init-state.json"
            env         = false
        }

        env {
            CONTRACT_SRC="../dist/contracts/relay-registry.js"
            INIT_STATE="../dist/contracts/relay-registry-init-state.json"
        }

        restart {
            attempts = 0
            mode = "fail"
        }

        resources {
            cpu    = 4096
            memory = 4096
        }
    }
}