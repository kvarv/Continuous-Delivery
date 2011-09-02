using NUnit.Framework;

namespace ContinuousDelivery.WpfApplication.Tests
{
	[TestFixture]
	public class SillyTests
	{
		 [Test]
		 public void Should_be_true()
		 {
		 	Assert.IsTrue(true);
		 }

		 [Test]
		 public void Should_be_false()
		 {
			 Assert.IsFalse(false);
		 }
	}
}