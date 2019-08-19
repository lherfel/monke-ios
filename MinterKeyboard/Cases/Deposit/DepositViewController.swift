import UIKit
import MinterMy
import RxSwift
import EFQRCode
import SVProgressHUD
import AlamofireImage

class DepositViewController: UIViewController {
	
	// MARK: - Properties.
	
	var address: String = ""
	
	// MARK: - Outlets.
	
	@IBOutlet weak var qrImageView: UIImageView!
	@IBOutlet weak var codeLabel: UILabel!
	@IBOutlet weak var imageCopyView: CopyView!
	@IBOutlet weak var textCopyView: CopyView!
	@IBOutlet weak var avatarImageView: UIImageView!
	@IBOutlet weak var clipboardButton: UIButton!
	
	// MARK: -
	
	var disposeBag = DisposeBag()
	
	// MARK: - Lifecycle.
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	func setup() {
		address = "Mx" + Session.shared.account.address
		if address.isValidAddress() {
			let avatarURL = MinterMyAPIURL.avatarAddress(address: address).url()
			avatarImageView.af_setImage(withURL: avatarURL)
		}
		
		let qr = EFQRCode.generate(content: address)
		let image = (qr != nil) ? UIImage(cgImage: qr!) : UIImage()
		
		qrImageView.image = image
		codeLabel.text = address
		imageCopyView.configure(text: address)
		textCopyView.configure(text: address)
		
		clipboardButton.rx.tap.subscribe(onNext: { (_) in
			UIPasteboard.general.string = self.address
			SVProgressHUD.showSuccess(withStatus: "COPIED")
		}).disposed(by: disposeBag)
	}
}

