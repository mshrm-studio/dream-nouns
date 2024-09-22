using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;
using Nethereum.Hex.HexTypes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;
using Nethereum.Web3;
using Nethereum.Contracts.CQS;
using Nethereum.Util;
using Nethereum.Web3.Accounts;
using Nethereum.Hex.HexConvertors.Extensions;
using Nethereum.Contracts;
using Nethereum.Contracts.Extensions;
using Nethereum.RPC.Eth.DTOs;

namespace DreamNoun.Spawner.Console.Models
{
    public partial class GetDreamNounMatchFunction : GetDreamNounMatchFunctionBase { }

    [Function("getDreamNounMatch")]
    public class GetDreamNounMatchFunctionBase : FunctionMessage
    {
    }

    [FunctionOutput()]
    public class TestFunctionOutputDTO : IFunctionOutputDTO
    {
        [Parameter("uint256", "BlockNumber", 0)]
        public BigInteger BlockNumber { get; set; }
    }

    [FunctionOutput()]
    public class MatchedDreamNounResponseFunctionOutputDTO : IFunctionOutputDTO
    {
        [Parameter("tuple")]
        public MatchedDreamNounResponse MatchedDreamNounResponse { get; set; }
    }

    public class MatchedDreamNounResponse
    {
        [Parameter("bool", "HasMatched", 0)]
        public bool HasMatched { get; set; }

        [Parameter("uint256", "BlockNumber", 1)]
        public BigInteger BlockNumber { get; set; }

        [Parameter("string", "NounsTraitsKey", 2)]
        public string NounsTraitsKey { get; set; }

        [Parameter("uint256", "DreamNounIndex", 3)]
        public BigInteger DreamNounIndex { get; set; }

        [Parameter("uint48", "Background", 4)]
        public BigInteger Background { get; set; }

        [Parameter("uint48", "Body", 5)]
        public BigInteger Body { get; set; }

        [Parameter("uint48", "Accessory", 6)]
        public BigInteger Accessory { get; set; }

        [Parameter("uint48", "Head", 7)]
        public BigInteger Head { get; set; }

        [Parameter("uint48", "Glasses", 8)]
        public BigInteger Glasses { get; set; }
    }
}
