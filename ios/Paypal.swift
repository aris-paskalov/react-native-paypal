import PayPalCheckout

@objc(Paypal)
class Paypal: NSObject {
    @objc func startWithOrderId(
        _
            options: NSDictionary,
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        let clientID = options["clientID"] as? String ?? ""
        let returnUrl = options["returnUrl"] as? String ?? ""
        let orderId = options["orderId"] as? String ?? ""
        let useSandbox = options["useSandbox"] as? Bool ?? true
        
        let environment = useSandbox ? Environment.sandbox : Environment.live
        let config = CheckoutConfig(
            clientID: clientID,
            returnUrl: returnUrl,
            environment: environment
        )
        
        Checkout.set(config: config)
        
        Checkout.setCreateOrderCallback { createOrderActions in
            createOrderActions.set(orderId: orderId)
        }
        
        Checkout.setOnApproveCallback { approval in
            resolver(approval.data)
        }
        
        Checkout.setOnCancelCallback { error in
            rejecter("PAYPAL_CANCELLED", "The user cancelled", nil)
        }
        
        Checkout.setOnErrorCallback { error in
            rejecter("PAYPAL_ERROR", error.reason, nil)
        }
        
        DispatchQueue.main.async {
            Checkout.start()
        }
    }
}
