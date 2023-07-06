using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;

namespace MtbTokenMaster.Contracts.Vesting.ContractDefinition
{
    public partial class VestingSchedule : VestingScheduleBase { }

    public class VestingScheduleBase 
    {
        [Parameter("address", "beneficiary", 1)]
        public virtual string Beneficiary { get; set; }
        [Parameter("uint8", "claimedPeriods", 2)]
        public virtual byte ClaimedPeriods { get; set; }
        [Parameter("uint8", "totalPeriods", 3)]
        public virtual byte TotalPeriods { get; set; }
        [Parameter("uint256", "periodDuration", 4)]
        public virtual BigInteger PeriodDuration { get; set; }
        [Parameter("uint256", "cliff", 5)]
        public virtual BigInteger Cliff { get; set; }
        [Parameter("uint256", "startTime", 6)]
        public virtual BigInteger StartTime { get; set; }
        [Parameter("uint256", "amountTotal", 7)]
        public virtual BigInteger AmountTotal { get; set; }
        [Parameter("uint256", "released", 8)]
        public virtual BigInteger Released { get; set; }
    }
}
