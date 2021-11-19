// THIS FILE IS GENERATED BY HARDHAT-CIRCOM. DO NOT EDIT THIS FILE.

//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.5
//      fixed linter warnings
//      added requiere error messages
//
pragma solidity ^0.6.7;

library Pairing {
    struct G1Point {
        uint256 X;
        uint256 Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return
            G2Point(
                [
                    11559732032986387107991004021392285783925812861821192530917403151452391805634,
                    10857046999023057135944570762232829481370756359578518086990519993285655852781
                ],
                [
                    4082367875863433681332203403145435568316851327593401208105741076214120093531,
                    8495653923123431417604973247489272438418190587263600148770280649306958101930
                ]
            );

        /*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }

    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        // The prime q in the base field F_q for G1


            uint256 q
         = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }

    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2)
        internal
        view
        returns (G1Point memory r)
    {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
                case 0 {
                    invalid()
                }
        }
        require(success, "pairing-add-failed");
    }

    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint256 s)
        internal
        view
        returns (G1Point memory r)
    {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
                case 0 {
                    invalid()
                }
        }
        require(success, "pairing-mul-failed");
    }

    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2)
        internal
        view
        returns (bool)
    {
        require(p1.length == p2.length, "pairing-lengths-failed");
        uint256 elements = p1.length;
        uint256 inputSize = elements * 6;
        uint256[] memory input = new uint256[](inputSize);
        for (uint256 i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint256[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(
                sub(gas(), 2000),
                8,
                add(input, 0x20),
                mul(inputSize, 0x20),
                out,
                0x20
            )
            // Use "invalid" to make gas estimation work
            switch success
                case 0 {
                    invalid()
                }
        }
        require(success, "pairing-opcode-failed");
        return out[0] != 0;
    }

    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }

    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }

    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

library Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function verify(
        uint256[] memory input,
        Proof memory proof,
        VerifyingKey memory vk
    ) internal view returns (uint256) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        require(input.length + 1 == vk.IC.length, "verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint256 i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field, "verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (
            !Pairing.pairingProd4(
                Pairing.negate(proof.A),
                proof.B,
                vk.alfa1,
                vk.beta2,
                vk_x,
                vk.gamma2,
                proof.C,
                vk.delta2
            )
        ) return 1;
        return 0;
    }

    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[] memory input,
        VerifyingKey memory vk
    ) internal view returns (bool) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        if (verify(input, proof, vk) == 0) {
            return true;
        } else {
            return false;
        }
    }

   
    function signVerifyingKey() internal pure returns (VerifyingKey memory vk) {
      vk.alfa1 = Pairing.G1Point(19642524115522290447760970021746675789341356000653265441069630957431566301675,15809037446102219312954435152879098683824559980020626143453387822004586242317);
      vk.beta2 = Pairing.G2Point([6402738102853475583969787773506197858266321704623454181848954418090577674938,3306678135584565297353192801602995509515651571902196852074598261262327790404], [15158588411628049902562758796812667714664232742372443470614751812018801551665,4983765881427969364617654516554524254158908221590807345159959200407712579883]);
      vk.gamma2 = Pairing.G2Point([11559732032986387107991004021392285783925812861821192530917403151452391805634,10857046999023057135944570762232829481370756359578518086990519993285655852781], [4082367875863433681332203403145435568316851327593401208105741076214120093531,8495653923123431417604973247489272438418190587263600148770280649306958101930]);
      vk.delta2 = Pairing.G2Point([21173502052847522712343920695345049565520895905384250222105697507142194555901,2331074035208661256364667123862169704061449951851910379325063964198285430221], [1921085277078744684511176971830319952173319902281081603728474458216922605612,961901284356507153388088069199380552581103880001797976871193700998289486054]);
      vk.IC = new Pairing.G1Point[](43);
    vk.IC[0] = Pairing.G1Point(657562608464374721230143788396249523549410531750032061216610607917284600953,13172681097404369403523869773745136175261959357116379651994788915893101183215);
        vk.IC[1] = Pairing.G1Point(17499199031785140743922878409865340426328940636850325038002269285709147406606,2873383829407937637401718180882197721698876107557194356449174986427549704707);
        vk.IC[2] = Pairing.G1Point(1740579878878756998224329882989032329774963792285233583266207154859669463960,5970869600462561526758628547176356424881592988513263476301885839512029535774);
        vk.IC[3] = Pairing.G1Point(7974577527952998588026734205191509837863476840340157051985941522564241598611,17019495926249287838693180080119032536762179953184830279436360977062846932198);
        vk.IC[4] = Pairing.G1Point(8736364122310449933760683466244345836653012206512531992549870260092527428847,10254814914450423336101242918580648772487800397681210449233576857799033852795);
        vk.IC[5] = Pairing.G1Point(6590892025335726940234791382804483940742157414294267046865490729714689060767,3097428581948072632125073655560580513382897296308234131057918365584678700922);
        vk.IC[6] = Pairing.G1Point(5104180799175711582544473628908542739467477658534996136686787754760318963408,6719452562606021332372241599903661975284078802927231440327146538857643707012);
        vk.IC[7] = Pairing.G1Point(15694593735773782626185613053832279677165885854130246702119884430545286308533,15833803007366873825816215410598971151047362138758777923446042753775672171752);
        vk.IC[8] = Pairing.G1Point(6995601169390490083939056752496701617891044811229517626271075429474802801102,12997633201708473644321579454445742279584398318322506248276320433120095905407);
        vk.IC[9] = Pairing.G1Point(11715327563047309457335139125376898117644339273568862521137970835886213839923,14005780295685029269837225501910068402486842565971048109608036125407105104384);
        vk.IC[10] = Pairing.G1Point(3889066403348688077066025338027608660850974914772266485139638594884390917589,6155566167520957697238980817182637676404937076087549942921437006063560526925);
        vk.IC[11] = Pairing.G1Point(11186567761746769014333391458224828055441342291455843019092676523876929470063,18282415504893632574009395847836168727911345530810056117736800309242786138064);
        vk.IC[12] = Pairing.G1Point(18073929500239297336230242622871953462480691092851271575720746254686859709947,1158077456311680563085071776995026115357526248263737257722790978629273722467);
        vk.IC[13] = Pairing.G1Point(1158452481388123121831716218749616427188239156217579108365308430560191005263,15822959974704921079386022323467036472904365199443044251758987856744550614271);
        vk.IC[14] = Pairing.G1Point(1172822520625302742585430665903002287308828342827865941481095076356611826787,18408527908866781456743034414116370166053805491791125071769344000122344193056);
        vk.IC[15] = Pairing.G1Point(19894712511892410938204121448919881982136520485922087850417313829519808826818,14329610022620096597977305502612691932017477738755318198839490998538318723426);
        vk.IC[16] = Pairing.G1Point(14442850940906495220429696380423274991995829219572133634359798415240854844023,10274737676690068118166739280844809403213652123481184380780285489728176833237);
        vk.IC[17] = Pairing.G1Point(15783286396940676373293030420891217121886361652836238147139828300893421235538,13922333558416436637665445656057707373931048137799482030877243374266160694886);
        vk.IC[18] = Pairing.G1Point(8942113289018894050442266450951215977267822211193289017167464955736744288554,6788942106440198784921942735680205117313691496869682885643601394321395557830);
        vk.IC[19] = Pairing.G1Point(9993878258445071232602609943898684245212011704360183394639861988442469519367,6610231060847729361827834510134320867525610314727687018364653702705519194131);
        vk.IC[20] = Pairing.G1Point(11380700861127358669667335549712317208150990013900935383271206482753816881471,2839514946235146263790459053085196817469250204301773108676732448808528246995);
        vk.IC[21] = Pairing.G1Point(6831592124631281369021938756967104261062679843407469159628026228952192071923,16818311253140925493273427146600505296924312573318437902639170708201105170315);
        vk.IC[22] = Pairing.G1Point(12605466432985338858690858804873706585857862483275282057925349563749491649958,5752886123357495911121753117405207609709300087163138410770446584472749354013);
        vk.IC[23] = Pairing.G1Point(4360211738860034135866245197460924031094159186254529450097814483169405724779,10070352663520425931529643475098079894848200710486847376817005448718315571503);
        vk.IC[24] = Pairing.G1Point(8863441100385607788201168859082510629669981256913911700735103118560889562406,20925958796494766567728565149961147874752790935472489935220681834898025189115);
        vk.IC[25] = Pairing.G1Point(17755025290609066286147909557661712800338072492489084773519980683924881369795,20159096048399999804232764510011273626335632435760691077894022469912137403236);
        vk.IC[26] = Pairing.G1Point(6718629581069864409050121314586251169748716604643636248265776272112199880309,18713312834185197059034413104649878843515370027340742764105039730917186695261);
        vk.IC[27] = Pairing.G1Point(15178687408092529266212950903933831579524741651216823491955274342421730809599,21599129379936179239696866417905762752590903609654799847464945823137998395491);
        vk.IC[28] = Pairing.G1Point(1326817006953878094805681751647756473977681305134013617732714254896694835417,16786766831903203161987652134950489482796430056814181361208218698036599600345);
        vk.IC[29] = Pairing.G1Point(12751631999092640631222763717731109498512005708098289572980751613047314743472,3466868534600275354174982763138735553100305930214135813027577538723350746857);
        vk.IC[30] = Pairing.G1Point(16748028885499535116030129237008781165246723975047599530031556086782063063259,13576841430601632451940890104281086159080352713464612123047052088094770047770);
        vk.IC[31] = Pairing.G1Point(9511548639315467817853952567107111853863972067317022115149276139109930853370,18763119916889176672390557510119069753821611514393342688399111879756317382053);
        vk.IC[32] = Pairing.G1Point(7477964207369620048903777683128350582249179396459286509812024471589673172252,21376916372858927882624591029292054265820409714402012546816392462511603359995);
        vk.IC[33] = Pairing.G1Point(10676766010252586501665384524443879668632907866293464682226567297468948594975,16945945569760257266834440419867072019068184456075058891909136809977166499681);
        vk.IC[34] = Pairing.G1Point(11743617024009108578475501078404017787369531532077156045838755901385563181890,18169872084869153525336725897835016023944405758980570639277845555845662734842);
        vk.IC[35] = Pairing.G1Point(18620360675192995778871643354413617341436203941143993388370475390985854297326,1635239123880253811318416457063132778946152154108025015621093557176398214478);
        vk.IC[36] = Pairing.G1Point(21562947318383625443842857142385601566172604735057534054122965599719946041987,9666169557758691736136420700756541275566436712669088614595954036262125771711);
        vk.IC[37] = Pairing.G1Point(6762681934950223054921556039077192141591149366033009299317587452473046742546,4012525113209000451406061762815440719374879061355413707740521355108461406186);
        vk.IC[38] = Pairing.G1Point(13203706716280500485943845443457309690951375916850228342660072130000398035672,5823435741515177366380908958805847754846233026572449586599467677193306525704);
        vk.IC[39] = Pairing.G1Point(5719057517948267427767997972121224277906159669131765013263207909366817476403,20442288243965151338596077887493404947623073531952024267920782729969182387755);
        vk.IC[40] = Pairing.G1Point(20717360284645590928774588505884440526794414405759171729107781940706060149870,19904089395013989161859634291703972439067787463795239093948539985942981561145);
        vk.IC[41] = Pairing.G1Point(18858414448419458101062297386560101111824327068757480237800795339303287646212,20202571476330956969326875549051203132665349378253942894510819954999312255190);
        vk.IC[42] = Pairing.G1Point(8916610685360553788676956626896788316916568776887881129939995199570998536577,14824162202514030610268781757590156940062407436846068720716729991310976708693);

    }

    function verifySignProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[42] memory input
    ) public view returns (bool) {
        uint256[] memory inputValues = new uint256[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        return verifyProof(a, b, c, inputValues, signVerifyingKey());
    }
    function revealVerifyingKey() internal pure returns (VerifyingKey memory vk) {
      vk.alfa1 = Pairing.G1Point(19642524115522290447760970021746675789341356000653265441069630957431566301675,15809037446102219312954435152879098683824559980020626143453387822004586242317);
      vk.beta2 = Pairing.G2Point([6402738102853475583969787773506197858266321704623454181848954418090577674938,3306678135584565297353192801602995509515651571902196852074598261262327790404], [15158588411628049902562758796812667714664232742372443470614751812018801551665,4983765881427969364617654516554524254158908221590807345159959200407712579883]);
      vk.gamma2 = Pairing.G2Point([11559732032986387107991004021392285783925812861821192530917403151452391805634,10857046999023057135944570762232829481370756359578518086990519993285655852781], [4082367875863433681332203403145435568316851327593401208105741076214120093531,8495653923123431417604973247489272438418190587263600148770280649306958101930]);
      vk.delta2 = Pairing.G2Point([21173502052847522712343920695345049565520895905384250222105697507142194555901,2331074035208661256364667123862169704061449951851910379325063964198285430221], [1921085277078744684511176971830319952173319902281081603728474458216922605612,961901284356507153388088069199380552581103880001797976871193700998289486054]);
      vk.IC = new Pairing.G1Point[](4);
    vk.IC[0] = Pairing.G1Point(15102441537367985715480762740430901065913293683653860615278696558633952693562,18205230909710994402777522080597486043028658566359195135280362221642987840942);
        vk.IC[1] = Pairing.G1Point(3685796016513330110525812872602837051792870925102827661913808627401863131021,11472377218085827339010106150461221025375016127956016387461214801069794699726);
        vk.IC[2] = Pairing.G1Point(11930233378821726705418962443872710075528244153223179764691566561016423751882,19961857787239703149258511294770579550819931086937279769215635586167886092418);
        vk.IC[3] = Pairing.G1Point(9563582119941021439713272162803242180999592044440781760297609915570916636348,2266614030418436906531449715440479181465902219241216478647248073931900251554);

    }

    function verifyRevealProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[3] memory input
    ) public view returns (bool) {
        uint256[] memory inputValues = new uint256[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        return verifyProof(a, b, c, inputValues, revealVerifyingKey());
    }
    function denyVerifyingKey() internal pure returns (VerifyingKey memory vk) {
      vk.alfa1 = Pairing.G1Point(19642524115522290447760970021746675789341356000653265441069630957431566301675,15809037446102219312954435152879098683824559980020626143453387822004586242317);
      vk.beta2 = Pairing.G2Point([6402738102853475583969787773506197858266321704623454181848954418090577674938,3306678135584565297353192801602995509515651571902196852074598261262327790404], [15158588411628049902562758796812667714664232742372443470614751812018801551665,4983765881427969364617654516554524254158908221590807345159959200407712579883]);
      vk.gamma2 = Pairing.G2Point([11559732032986387107991004021392285783925812861821192530917403151452391805634,10857046999023057135944570762232829481370756359578518086990519993285655852781], [4082367875863433681332203403145435568316851327593401208105741076214120093531,8495653923123431417604973247489272438418190587263600148770280649306958101930]);
      vk.delta2 = Pairing.G2Point([21173502052847522712343920695345049565520895905384250222105697507142194555901,2331074035208661256364667123862169704061449951851910379325063964198285430221], [1921085277078744684511176971830319952173319902281081603728474458216922605612,961901284356507153388088069199380552581103880001797976871193700998289486054]);
      vk.IC = new Pairing.G1Point[](4);
    vk.IC[0] = Pairing.G1Point(11926936633014657560426507478123940680519558494126257829902672304395535642395,11290317027296882960470179285814067040557131291140677840343647053058482214491);
        vk.IC[1] = Pairing.G1Point(3547206088738065592706127421099339330576942219006858355805633668254957357454,3895135774787815304976616270965731955562953461849607165428247463505052012643);
        vk.IC[2] = Pairing.G1Point(9831777171284463678463002701138378063565241667798600475248332962052868032295,12902079986022685891552781415219335450063212123808973792015379106572325766321);
        vk.IC[3] = Pairing.G1Point(16649201314728823180495601229861541545582842231764728231049735641778764240940,4778164009457223052757260785117921613134760151474345554659778771412370474740);

    }

    function verifyDenyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[3] memory input
    ) public view returns (bool) {
        uint256[] memory inputValues = new uint256[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            inputValues[i] = input[i];
        }
        return verifyProof(a, b, c, inputValues, denyVerifyingKey());
    }
}
